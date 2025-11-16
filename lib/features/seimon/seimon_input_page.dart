import 'package:flutter/material.dart';

import 'seimon_calculator.dart';
import 'seimon_result_page.dart';

class SeimonInputPage extends StatefulWidget {
  const SeimonInputPage({super.key});

  @override
  State<SeimonInputPage> createState() => _SeimonInputPageState();
}

class _SeimonInputPageState extends State<SeimonInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // 生年月日（西暦4桁を 0〜9 ボタンで入力）
  int? _yearThousands;
  int? _yearHundreds;
  int? _yearTens;
  int? _yearOnes;
  int? _month;
  int? _day;

  // 入力中の桁（どこに数字が入るか）
  _YearField _activeYearField = _YearField.thousands;

  // 性別 'male' / 'female' / 'other'
  String? _gender;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _setYearDigit(int digit) {
    setState(() {
      switch (_activeYearField) {
        case _YearField.thousands:
          _yearThousands = digit;
          _activeYearField = _YearField.hundreds;
          break;
        case _YearField.hundreds:
          _yearHundreds = digit;
          _activeYearField = _YearField.tens;
          break;
        case _YearField.tens:
          _yearTens = digit;
          _activeYearField = _YearField.ones;
          break;
        case _YearField.ones:
          _yearOnes = digit;
          // 4桁埋まったあとはそのまま ones にしておく（必要なら戻してもOK）
          break;
      }
    });
  }

  void _clearYear() {
    setState(() {
      _yearThousands = null;
      _yearHundreds = null;
      _yearTens = null;
      _yearOnes = null;
      _activeYearField = _YearField.thousands;
    });
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();

    if (_gender == null ||
        _yearThousands == null ||
        _yearHundreds == null ||
        _yearTens == null ||
        _yearOnes == null ||
        _month == null ||
        _day == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('生年月日と性別をすべて入力してください')));
      return;
    }

    // 西暦の組み立て（2,0,0,1 → 2001）
    final year =
        _yearThousands! * 1000 +
        _yearHundreds! * 100 +
        _yearTens! * 10 +
        _yearOnes!;

    DateTime birthDate;
    try {
      birthDate = DateTime(year, _month!, _day!);
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('存在しない日付です（例：2月30日など）')));
      return;
    }

    // 星紋姓名術ロジックでタイプを決定
    final typeCode = SeimonCalculator.calcTypeCode(
      name: name,
      birthDate: birthDate,
      gender: _gender!, // 'male' / 'female' / 'other'
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeimonResultPage(
          name: name,
          birthDate: birthDate,
          gender: _gender!,
          typeCode: typeCode,
        ),
      ),
    );
  }

  Widget _buildYearBox(String label, int? digit, bool isActive) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.amber : Colors.grey,
              width: isActive ? 2 : 1,
            ),
            color: Colors.black.withOpacity(0.05),
          ),
          child: Text(
            digit?.toString() ?? '',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.amber : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberPad() {
    final digits = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: digits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final d = digits[index];
        return ElevatedButton(
          onPressed: () => _setYearDigit(d),
          style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(
            d.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('姓名判断（星紋姓名術）')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('名前と生年月日から星紋タイプを占います。', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),

                // 名前
                Text('お名前', style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: '例）山田 太郎',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '名前を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 性別
                Text('性別', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _GenderChip(
                      label: '男性',
                      value: 'male',
                      groupValue: _gender,
                      onSelected: (v) {
                        setState(() => _gender = v);
                      },
                    ),
                    _GenderChip(
                      label: '女性',
                      value: 'female',
                      groupValue: _gender,
                      onSelected: (v) {
                        setState(() => _gender = v);
                      },
                    ),
                    _GenderChip(
                      label: 'その他',
                      value: 'other',
                      groupValue: _gender,
                      onSelected: (v) {
                        setState(() => _gender = v);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 生年月日
                Text('生年月日（西暦）', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),

                // 年の4桁表示
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _activeYearField = _YearField.thousands);
                      },
                      child: _buildYearBox(
                        '千の位',
                        _yearThousands,
                        _activeYearField == _YearField.thousands,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _activeYearField = _YearField.hundreds);
                      },
                      child: _buildYearBox(
                        '百の位',
                        _yearHundreds,
                        _activeYearField == _YearField.hundreds,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _activeYearField = _YearField.tens);
                      },
                      child: _buildYearBox(
                        '十の位',
                        _yearTens,
                        _activeYearField == _YearField.tens,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _activeYearField = _YearField.ones);
                      },
                      child: _buildYearBox(
                        '一の位',
                        _yearOnes,
                        _activeYearField == _YearField.ones,
                      ),
                    ),
                    const Spacer(),
                    TextButton(onPressed: _clearYear, child: const Text('クリア')),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  '↓ 0〜9のボタンをタップして西暦4桁を入力',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),

                _buildNumberPad(),
                const SizedBox(height: 16),

                // 月・日
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('月', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: DropdownButton<int>(
                              value: _month,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(8),
                              underline: const SizedBox.shrink(),
                              hint: const Text('月'),
                              items: List.generate(
                                12,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text('${i + 1} 月'),
                                ),
                              ),
                              onChanged: (v) {
                                setState(() => _month = v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('日', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: DropdownButton<int>(
                              value: _day,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(8),
                              underline: const SizedBox.shrink(),
                              hint: const Text('日'),
                              items: List.generate(
                                31,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text('${i + 1} 日'),
                                ),
                              ),
                              onChanged: (v) {
                                setState(() => _day = v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onSubmit,
                    child: const Text('占う'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _YearField { thousands, hundreds, tens, ones }

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String? groupValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(value),
    );
  }
}
