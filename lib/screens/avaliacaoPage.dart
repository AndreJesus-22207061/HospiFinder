import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prjectcm/models/evaluation_report.dart';
import 'package:prjectcm/models/hospital.dart';
import 'package:provider/provider.dart';
import 'package:prjectcm/data/sns_repository.dart';
import 'package:testable_form_field/testable_form_field.dart';
import 'package:dropdown_search/dropdown_search.dart';



class AvaliacaoPage extends StatefulWidget {

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
  final _formKey = GlobalKey<FormState>();

  Hospital?  _selectedHospital;
  int? _avaliacao;
  late DateTime _selectedDate;
  String? _notas;
  bool _submitSucesso = false;

  @override

  void initState(){
    super.initState();
    _selectedDate = DateTime.now();
  }


  Widget build(BuildContext context) {

    final snsRepository = Provider.of<SnsRepository>(context);
    final List<Hospital> listaHospitais = snsRepository.listarHospitais();
    //final userLat = snsRepository.latitude;
    //final userLon = snsRepository.longitude;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 22.0, right: 24.0, top: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHospitalFormField(listaHospitais),
                SizedBox(height: 16),
                _buildAvaliacaoFormField(),
                SizedBox(height: 16),
                _buildDateFormField(),
                SizedBox(height: 16),
                _buildNotasFormField(),
                SizedBox(height: 9),
                ElevatedButton(
                  key: Key('evaluation-form-submit-button'),
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    minimumSize: Size(150, 48), // largura mínima 200, altura 48
                  ),
                  child: Text("Submeter",
                    style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                if(_submitSucesso)
                  Text(
                    "Submetido com Sucesso",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FormField<Hospital> _buildHospitalFormField(List<Hospital> hospitais) {
    return TestableFormField<Hospital>(
      key: Key('evaluation-hospital-selection-field'),
      getValue: () => _selectedHospital!,
      internalSetValue: (state, value) {
        _selectedHospital = value;
        state.didChange(value);
      },
      validator: (value) => value == null ? 'Escolhe um hospital' : null,
      onSaved: (value) {
        _selectedHospital = value!;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownSearch<Hospital>(
              selectedItem: _selectedHospital,
              items: hospitais,
              itemAsString: (Hospital h) => h.name,
              dropdownBuilder: (context, selectedItem) {
                return Text(
                  selectedItem?.name ?? 'Selecione o Hospital',
                  style: TextStyle(
                    color: selectedItem == null ? Colors.grey : Colors.black,
                    fontStyle: selectedItem == null ? FontStyle.italic : FontStyle.normal,
                  ),
                );
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: 'Hospital',
                  hintText: 'Selecione o Hospital',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  errorText: field.errorText,
                ),
              ),
              onChanged: (Hospital? value) {
                field.didChange(value);
              },
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar hospital',
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  FormField<int> _buildAvaliacaoFormField() {
    return TestableFormField<int>(
      key: Key('evaluation-rating-field'),
      getValue: () => _avaliacao!,
      internalSetValue: (state, value) {
        _avaliacao = value;
        state.didChange(value);
      },
      validator: (value) => value == null ? 'Preencha a avaliação' : null,
      onSaved: (value) {
        _avaliacao = value;
      },
      builder: (field) {
        final borderColor = field.hasError ? Colors.red : Colors.blue;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Avaliação (1 a 5 estrelas)',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
                errorText: field.errorText,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final estrela = index + 1;
                  final isSelected = field.value != null && field.value! >= estrela;
                  return GestureDetector(
                    onTap: () {
                      field.didChange(estrela);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                      ),
                      child: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isSelected ? Colors.blue : Colors.grey,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }




  FormField<DateTime> _buildDateFormField() {
    TextEditingController _controller = TextEditingController();

    return TestableFormField<DateTime>(
      key: Key('evaluation-datetime-field'),
      getValue: () => _selectedDate,
      internalSetValue: (state, value) {
        _selectedDate = value;
        state.didChange(value);
        _controller.text = DateFormat('dd/MM/yyyy HH:mm').format(value);
      },
      validator: (value) {
        if (value == null) {
          return 'Preenche uma data e hora válidas';
        }
        return null;
      },
      onSaved: (value) {
        _selectedDate = value!;
      },
      builder: (field) {
        final borderColor = field.hasError ? Colors.red : Colors.blue;

        return TextFormField(
          style: TextStyle(color: Colors.black),
          controller: _controller,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Data e Hora', // Texto flutuante na borda
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'dd/MM/yyyy HH:mm', // Hint dentro do campo
            hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            errorText: field.errorText,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
          onChanged: (value) {
            try {
              final parsed = DateFormat('dd/MM/yyyy HH:mm').parseStrict(value);
              field.didChange(parsed);
            } catch (e) {
              field.didChange(null); // marca como inválido
            }
          },
        );
      },
    );
  }



  FormField<String> _buildNotasFormField() {
    return TestableFormField<String>(
      key: Key('evaluation-comment-field'),
      getValue: () => _notas!,
      internalSetValue: (state, value) {
        _notas = value;
        state.didChange(value);
      },
      onSaved: (value){
        _notas = value ?? '';
      },
      builder: (field) {
        return TextField(
          style: TextStyle(color: Colors.black),
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Notas (Opcional)',
            labelStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorText: field.errorText,
          ),
          onChanged: (value) {
            field.didChange(value);
          },
        );
      },
    );
  }


  void _submit(){
    if (_formKey.currentState!.validate() ) {
      _formKey.currentState!.save();
      final novaAvaliacao = EvaluationReport(
        rating: _avaliacao!,
        dataHora: _selectedDate,
        notas: _notas,
      );

      final snsRepository = Provider.of<SnsRepository>(context, listen:false);
      snsRepository.addAvaliacao(novaAvaliacao, _selectedHospital!);

      setState(() {
        _submitSucesso = true;
      });

    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos obrigatórios!")
        ),
      );
    }
  }
}