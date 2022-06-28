import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:web_service/services/via_cep_service.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCepController = TextEditingController();
  bool _loading = false;
  bool _isCepValid = false;
  bool _enableField = true;
  String? _result;
  String _shareResult = '';

  @override
  void dispose() {
    super.dispose();
    _searchCepController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar CEP'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Show Snackbar',
            onPressed: () => _onShare(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildResultForm()
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return TextField(
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(labelText: 'Cep'),
      style: const TextStyle(fontSize: 20, color: Colors.black),
      controller: _searchCepController,
      enabled: _enableField,
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
        onPressed: _searchCep,
        child: _loading
            ? _circularLoading()
            : const Text(
                'CONSULTAR',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromARGB(255, 70, 70, 70)),
              ),
      ),
    );
  }

  void _searching(bool enable) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  Widget _circularLoading() {
    return const SizedBox(
      height: 15.0,
      width: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  Future _searchCep() async {
    _searching(true);
    final cep = _searchCepController.text;

    try {
      if (cep.length == 8) {
        _isCepValid = false;
        final resultCep = await ViaCepService.fetchCep(cep: cep);
        setState(() {
          _isCepValid = true;
          _result = resultCep.toJson();
          _buildResultForm();
        });

        _searching(false);
      } else {
        _searching(false);

        setState(() {
          _isCepValid = false;
          _buildResultForm();
        });

        await Flushbar(
          icon: const Icon(Icons.error_outline, color: Colors.white, size: 30),
          message: 'O CEP deve conter 8 digitos.',
          messageSize: 18,
          duration: const Duration(seconds: 3),
        ).show(context);
      }
    } catch (e) {
      _searching(false);

      setState(() {
        _isCepValid = false;
        _buildResultForm();
      });

      await Flushbar(
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 30),
        message: e.toString(),
        messageSize: 20,
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }

 
  Widget _buildResultForm() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(_result ?? ''),
    );
  }

  void _onShare() async {
    if (_isCepValid) {
      _shareResult = _result!;
      await Share.share(_shareResult);
    } else {
      await Flushbar(
        title: 'Erro ao compartilhar',
        message: 'Consulte um CEP antes de compartilhar',
        duration: const Duration(seconds: 3),
      ).show(context);
    }
  }
}
