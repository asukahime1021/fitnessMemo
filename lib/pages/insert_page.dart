import 'package:fitness_memo/constant/constant.dart';
import 'package:fitness_memo/constant/enum_machine.dart';
import 'package:fitness_memo/object/common.dart';
import 'package:fitness_memo/object/state.dart';
import 'package:fitness_memo/pages/calendar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsertPage extends ConsumerStatefulWidget {
  const InsertPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InsertPageState();
}

class _InsertPageState extends ConsumerState {

  bool _dispLeftRight = false;
  bool _dispDistance = false;
  DateTime _dispDate = DateTime.now();
  Machine _selectedValue = Machine.abdominal;
  int _selectedLR = 1;
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _error = "";

  Future<void> _datePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context, 
      initialDate: _dispDate, 
      firstDate: firstDay, 
      lastDate: lastDay);
    
    if (pickedDate == null) {
      return;
    }

    setState(() {
      _dispDate = pickedDate;
    });
  }

  void onChangeMachine(Machine value) {
    setState(() {
      _selectedValue = value;

      switch(value) {
        case Machine.rotaryTorso: 
          _dispLeftRight = true;
          _dispDistance = false;
          break;
        case Machine.treadmil: 
          _dispLeftRight = false;
          _dispDistance = true; 
          break;
        default: 
          _dispLeftRight = false;
          _dispDistance = false;
      }
    });
  }

  void onChangeLeftRighe(int value) {
    setState(() {
      _selectedLR = value;
    });
  }

  void onError(String message) {
    setState(() {
      _error = message;
    });
  }

  Widget _widgetDate() => InsertElement([
    Text("${_dispDate.year}/${_dispDate.month}/${_dispDate.day}"),
    IconButton(
      onPressed: () => _datePicker(context), 
      icon: const Icon(Icons.calendar_month))
  ]);

  Widget _widgetMachine() => InsertElement([
    DropdownButton(
      items: [
        for (var machine in Machine.values)
          DropdownMenuItem(child: Text(machine.name), value: machine)
      ],
      onChanged: (v) => onChangeMachine(v as Machine),
      value: _selectedValue,
    )
  ]);

  Widget _widgetLeftRight() => InsertElement([
    DropdownButton(
      items: const [
        DropdownMenuItem(child: Text("左"), value: 1),
        DropdownMenuItem(child: Text("右"), value: 2)
      ],
      onChanged: (v) => onChangeLeftRighe(v as int),
      value: _selectedLR
    )
  ]);

  Widget _widgetCount() => InsertElement([
    SizedBox(
      width: 30, 
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _countController,
      )
    ),
    const Text("回")
  ]);

  Widget _widgetWeight() => InsertElement([
    SizedBox(
      width: 30,
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: _weightController,
      )
    ),
    const Text("Kg")
  ]);

  Widget _widgetDistance() => InsertElement([
    SizedBox(
      width: 30,
      child: TextField(
        controller: _weightController,
      )
    ),
    const Text("Km")
  ]);

  Widget _widgetError() => InsertElement([
    Text(
      _error, 
      style: const TextStyle(color: Colors.red),
    )
  ]);

  // validation書く
  bool _validate() {
    if (_weightController.text.isEmpty || _countController.text.isEmpty) {
      onError("必須項目が未入力");
      return false;
    }
    onError("");
    return true;
  }

  String _getLeftOrRightString(int value) {
    return value == 1 ? "左" : "右";
  }

  Widget _widgetRegisterButton() => InsertElement([
    ElevatedButton(
      onPressed: () async {
        if (!_validate()) {
          return;
        }

        var _suffixWeight = _selectedValue == Machine.treadmil ? "Km" : "Kg";
        var _leftOrRight = _dispLeftRight ? _getLeftOrRightString(_selectedLR) : "";
        var _contents = "${_selectedValue.name} ${_countController.text}回 ${_weightController.text}$_suffixWeight $_leftOrRight";
        var _dateString = "${_dispDate.year}${_dispDate.month.toString().padLeft(2, "0")}${_dispDate.day.toString().padLeft(2, "0")}";

        await database!.addEvent(_contents, _dateString);

        var map = ref.read(eventListProvider);
        var list = map[_dispDate];
        if (list != null) {
          map[_dispDate] = [...list, _contents];
        } else {
          map[_dispDate] = [_contents];
        }
        ref.read(eventListProvider.notifier).addAll(map);

        Navigator
          .of(context)
          .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const CalendarPage()),
            (route) => false
          );
      }, 
      child: const Text("登録")
    )
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: insertAppBar),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _widgetDate(),
              _widgetMachine(),
              const SizedBox(height: 10),
              _widgetCount(),
              const SizedBox(height: 10),
              if (_dispLeftRight) _widgetLeftRight(),
              if (_dispDistance) _widgetDistance(),
              const SizedBox(height: 10),
              if (!_dispDistance) _widgetWeight(),
              const SizedBox(height: 10),
              if (_error.isNotEmpty) _widgetError(),
              _widgetRegisterButton(),
            ]
          )
        )
      )
    );
  }
}
