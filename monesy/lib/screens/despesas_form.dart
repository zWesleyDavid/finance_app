import 'package:flutter/material.dart';
import '../service/api_service.dart';

class DespesaForm extends StatefulWidget {
  final Map<String, dynamic>? despesa;

  DespesaForm({this.despesa});

  @override
  _DespesaFormState createState() => _DespesaFormState();
}

class _DespesaFormState extends State<DespesaForm> {
  final _formKey = GlobalKey<FormState>();
  String _titulo = '';
  String _descricao = '';
  String _valor = '';

  @override
  void initState() {
    super.initState();
    if (widget.despesa != null) {
      _titulo = widget.despesa!['titulo'];
      _descricao = widget.despesa!['descricao'] ?? '';
      _valor = widget.despesa!['valor'].toString();
    }
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final Map<String, dynamic> despesa = {
        'titulo': _titulo,
        'descricao': _descricao,
        'valor': double.parse(_valor),
      };
      try {
        if (widget.despesa == null) {
          await ApiService().addDespesa(despesa);
        } else {
          await ApiService().updateDespesa(widget.despesa!['id'], despesa);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar despesa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.despesa == null ? 'Adicionar Despesa' : 'Editar Despesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _titulo,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _titulo = value!;
                },
              ),
              TextFormField(
                initialValue: _descricao,
                decoration: InputDecoration(labelText: 'Descrição (Opcional)'),
                onSaved: (value) {
                  _descricao = value ?? '';
                },
              ),
              TextFormField(
                initialValue: _valor,
                decoration: InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um valor.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _valor = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
