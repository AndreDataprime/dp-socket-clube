import 'package:clube/models/cerva.dart';
import 'package:clube/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Cerva> cerva = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('grade', atualizaLista);

    super.initState();
  }

  atualizaLista(dynamic payload) {
    this.cerva =
        (payload as List).map((cerva) => Cerva.fromMap(cerva)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('grade');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text(
          'Lista de cervas',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          )
        ],
      ),
      body: Column(
        children: [
          _showGrafico(),
          Expanded(
            child: ListView.builder(
                itemCount: cerva.length,
                itemBuilder: (context, i) => _cervaList(cerva[i])),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: addCerva),
    );
  }

  Widget _cervaList(Cerva cerva) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
        key: Key(cerva.id),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) =>
            socketService.socket.emit('deletar', {'id': cerva.id}),
        background: Container(
          padding: EdgeInsets.only(left: 10.0),
          child: Align(alignment: Alignment.centerLeft, child: Text('Excluir')),
          color: Colors.red,
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(cerva.nome.substring(0, 2)),
          ),
          title: Text(cerva.nome),
          trailing: Text(
            '${cerva.votos}',
            style: TextStyle(fontSize: 20),
          ),
          onTap: () => socketService.socket.emit('votar', {'id': cerva.id}),
          //print(c.id),
        ));
  }

  addCerva() {
    //print('teste');
    final ctrl = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('Nova cerva'),
            content: TextField(
              controller: ctrl,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text('Salvar'),
                textColor: Colors.blue,
                elevation: 5,
                onPressed: () => addCervaToList(ctrl.text),
              )
            ]);
      },
    );
  }

  void addCervaToList(String nome) {
    if (nome.length > 1) {
      // this.cerva.add(
      //       Cerva(id: DateTime.now().toString(), nome: nome, votos: 0),
      //     );
      // setState(() {});
      final socketService = Provider.of<SocketService>(context, listen: false);
      //{'nome': nome}
      socketService.socket.emit('inserir', {'nome': nome});
    }
    Navigator.pop(context);
  }

  _showGrafico() {
    Map<String, double> dataMap = Map();
    cerva.forEach((cerva) {
      dataMap.putIfAbsent(cerva.nome, () => cerva.votos.toDouble());
    });
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
          width: double.infinity,
          height: 200,
          child: PieChart(dataMap: dataMap)),
    );
  }
}
