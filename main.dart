import 'package:universal_html/html.dart' as html;
import 'package:crypto/crypto.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage()
    );
  }
}

Future <bool> signUp(username, password, account, balance) async{
  final base = "http://10.0.2.2:5000";
  final response = await http.post("$base/signup/$username/$password/$account/$balance");
  final decoded = json.decode(response.body) as Map<String, dynamic>;
  if(decoded["success"] == "True"){
    return true;
  }
  else{
    return false;
  }
}
Future <bool> login(username, password) async{
  final base = "http://10.0.2.2:5000";
  final response = await http.post("$base/login/$username/$password");
  final decoded = json.decode(response.body) as Map<String, dynamic>;
  if(decoded["success"] == "True"){
    return true;
  }
  else{
    return false;
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageNum = 0;
  String _username;
  String _password;
  String _lastdate = "none";
  String _account;
  double _balance = 0.0;
  String _balanceString = "0.00";
  final String base = "http://10.0.2.2:5000";
  List accountsList;
  bool _isVisible = false;
  bool loggedIn = false;
  List _entryList;
  bool _darkmode = false;
  String currentColor = "red";
  Map myColors =
  {
  "red": {"primary": Color(0xffcf1b1b), "secondary":Color(0xff900d0d), "lighttext": Color(0xffffdbc5), "darktext": Color(0xff423144)},
  "green" : {"primary": Color(0xa7d129FF), "secondary": Color(0x616f39FF),"lighttext": Color(0xfff8eeb4), "darktext": Color(0xff1b1919)},
  "blue" : {"primary": Color(0x0f4c75FF), "secondary": Color(0x3282b8FF),"lighttext": Color(0xffbbe1fa), "darktext":Color(0xff1b262c)},
  "purple" : {"primary": Color(0x52057bFF), "secondary": Color(0x892cdcFF),"lighttext": Color(0xffbc6ff1), "darktext":Color(0xff000000)}
  };
  PageController controller = PageController(
    initialPage : 0
  );

  void changeColor(String color){
    setState(() {
      currentColor = color;
    });
  }


  String formatBalance(balance){
    List<String> subStrings = balance.split(".");
    String lastSub = subStrings[1];
    if(lastSub.length < 2){
      lastSub = lastSub + "0";
    }
    return subStrings[0]+"."+lastSub;
  }




  void openSignUp(BuildContext context) async{
    final _formkey = GlobalKey<FormState>();
    String tempUsername = "";
    String tempPassword = "";
    String tempAccount = "";
    double tempBalance = 0.00;
    bool failed = false;
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context){
        return Scaffold(
          appBar: AppBar(
            title: const Text('SignUp')
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(50)),
                      Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 32,
                        )
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Pick a Username',
                        ),
                        validator: (value){
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else if(value == 'user'){
                            failed = true;
                          }
                          else{
                            tempUsername = value;
                          }
                          return null;
                        },
                        onTap: (){
                          FocusScope.of(context).unfocus();
                        }
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Pick a Password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else{
                            var bytes = utf8.encode(value);
                            var digest = sha256.convert(bytes);
                            tempPassword = "$digest";
                          }
                          return null;
                        },
                        onTap: (){
                          FocusScope.of(context).unfocus();
                        }
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Pick a name for your first bank account',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else if(value == 'none'){
                            return 'Invalid bank account name';
                          }
                          else{
                            tempAccount = value;
                          }
                          return null;
                        },
                        onTap: (){
                          FocusScope.of(context).unfocus();
                        }
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Input an initial balance for your bank account',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          tempBalance = double.parse(value);
                          return null;
                        },
                        onTap: (){
                          FocusScope.of(context).unfocus();
                        }
                      ),
                      Padding(padding: const EdgeInsets.all(16)),
                      Text(
                        ((){
                        if(failed == true){
                          return "Username already Taken";
                        }
                        else{
                          return "";
                        }
                        })(),
                        style: TextStyle(color: Colors.red)
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () async{
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formkey.currentState.validate()) {
                              if (await signUp(tempUsername, tempPassword, tempAccount, tempBalance) == true){
                                Navigator.pop(context);
                                Navigator.pop(context);
                                setState(() {
                                  _isVisible = true;
                                });
                                _updateUserInfo([tempUsername,tempPassword,tempAccount,tempBalance]);
                                _MyHomePageState().build(context);
                              }
                              else{
                                failed = true;
                              }
                            }
                            (context as Element).reassemble();
                          },
                          child: Text('Submit'),
                        ),
                      ),
                    ],
                  )
                )
              )
            )
          )
        );
      }
    ));
  }












  void openLogin(BuildContext context) {
    final _formkey = GlobalKey<FormState>();
    String tempUsername;
    String tempPassword;
    bool failed = false;
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                child:Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(50)
                      ),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 32,
                        )
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter your Username',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else{
                            tempUsername = value;
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter your Password',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else{
                            var bytes = utf8.encode(value);
                            var digest = sha256.convert(bytes);
                            tempPassword = "$digest";
                          }
                          return null;
                        },
                      ),
                      Padding(padding: const EdgeInsets.all(16)),
                      Text(
                        ((){
                        if(failed == true){
                          return "User not found";
                        }
                        else{
                          return "";
                        }
                        })(),
                        style: TextStyle(color: Colors.red)
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () async{
                            if (_formkey.currentState.validate()) {
                              if (await login(tempUsername, tempPassword) == true){
                                setState(() {
                                  _isVisible = true;
                                  loggedIn = true;
                                });
                                _updateUserInfo([tempUsername, tempPassword]);
                                accountsList = await getAccounts();
                                _changeAccount(accountsList[0]);
                                print(_account);
                                http.get("$base");
                                Navigator.of(context).pop();
                              }
                              else{
                                failed = true;
                              }
                            }
                          },

                          child: Text('Submit'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("Don't Have an account?"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: ()async{
                            openSignUp(context);
                          },
                          child: Text('Sign Up'),
                        ),
                      ),
                    ]
                  )
                ),
              )
            )
          ),
        );
      },
    ));
  }








  void _createNewAccount(BuildContext context) async{
    final _formKey = GlobalKey<FormState>();
    String name = "";
    double bal = 0.0;
    bool valid = true;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Create New Account"),
          content: Builder(
            builder: (context){
              return Container(
                height: 220,
                width: 500,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Account Name',
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else{
                            name = value;
                          }
                          return null;
                        }
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Balance',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else{
                            bal = double.parse(value);
                          }
                          return null;
                        }
                      ),
                      Text(
                        ((){
                        if(valid == false){
                          return "Invalid Input";
                        }
                        else{
                          return "";
                        }
                        })(),
                        style: TextStyle(color: Colors.red)
                      ),
                      ElevatedButton(
                        onPressed: () async{
                          if (_formKey.currentState.validate()) {
                            final response = await http.post("$base/newaccount/$_username/$name/$bal");
                            final decoded = json.decode(response.body) as Map<String, dynamic>;
                            if(decoded["success"] == "True"){
                              Navigator.of(context).pop();
                              setState((){
                                _account = name;
                                _balance = bal;
                              });
                              _MyHomePageState().build(context);
                            }
                            else{
                              valid = false;
                            }
                          }
                          (context as Element).reassemble();
                        },
                        child: Text("Submit"),
                      )
                    ]
                  )
                )
              );
            }
          )
        );
      }
    );
  }




  void openTransactionForm(BuildContext context){
    final _formKey = GlobalKey<FormState>();
    String name;
    double ammount;
    String dropdownValue;
    String mainAccount;
    String secondAccount;

    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('New Entry'),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                child:Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      DropdownButton<String>(
                        hint: Text("Select a transaction type"),
                        value: dropdownValue,
                        icon: Icon(
                          Icons.arrow_downward,
                          color: Colors.red,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Colors.grey,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                          });
                          (context as Element).reassemble();
                        },
                        items: <String>['Deposit', 'Payment', 'Transfer']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      Visibility(
                        visible: dropdownValue == null ? false:true,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Transaction Name',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            name = value;
                            return null;
                          },
                        )
                      ),
                      Padding(padding: EdgeInsets.all(10.0)),
                      Visibility(
                        visible: dropdownValue == null? false:true, 
                        child: DropdownButton<String>(
                          hint: dropdownValue == "Transfer" ? Text("Transfer From"):Text("Account"),
                          value: mainAccount,
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Colors.red,
                          ),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              mainAccount = newValue;
                            });
                            (context as Element).reassemble();
                          },
                          items: accountsList
                              .map<DropdownMenuItem<String>>((final value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Visibility(
                        visible: dropdownValue == "Transfer" ? true:false, 
                        child: DropdownButton<String>(
                          hint: Text("Transfer To"),
                          value: secondAccount,
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Colors.red,
                          ),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              secondAccount = newValue;
                            });
                            (context as Element).reassemble();
                          },
                          items: accountsList
                              .map<DropdownMenuItem<String>>((final value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Visibility(
                        visible: dropdownValue == null ? false:true,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Ammount',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            }
                            ammount = double.parse(formatBalance(value));
                            return null;
                          },
                        )
                      ),
                      Padding(padding: EdgeInsets.all(20.0)),
                      Visibility(
                        visible: dropdownValue == null ? false:true,
                        child: ElevatedButton(
                          onPressed: () async{
                            if (_formKey.currentState.validate() && mainAccount != null) {
                              if(dropdownValue == "Payment" || dropdownValue == "Deposit"){
                                http.post("$base/newentry/single/$_username/$mainAccount/$dropdownValue/$name/$ammount");
                              }
                              else if(dropdownValue == "Transfer"){
                                if(secondAccount != null){
                                  http.post("$base/transfer/$_username/$mainAccount/$secondAccount/$name/$ammount");
                                }
                              }
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text("Submit"),
                        )
                      ),
                    ]
                  )
                ),
                
              )
            )
          ),
        );
      },
    ));
  }






  Future<List> getAccounts() async{
    final response = await http.get("$base/accounts/$_username");
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final accounts = decoded["accounts"];
    return accounts;
  } 
  void _changePage(int pageNum){
    controller.animateToPage(pageNum, duration: Duration(milliseconds: 500), curve: Curves.ease);
    setState(() {
      _pageNum = pageNum;
    });
  }
  void _updatePage(int pageNum){
    setState((){
      _pageNum = pageNum;
    });
  }
  void _logout(){
    setState(() {
      _username = null;
      _password = null;
      _account = null;
      _balance = 0.00;
      _balanceString = "0.00";
      accountsList = [];
      _isVisible = false;
      loggedIn = false;
    });
    _MyHomePageState().build(context);
  }
  void _updateUserInfo(List userInfo){
    _username = userInfo[0];
    _password = userInfo[1];
  }

  Widget _buildRow(int index){
    final row = _entryList[index];
    String name = row["name"];
    String ammount = row["ammount"].toString();
    String transType = row["pt"];
    print("Hello: $name");
    _lastdate = row["date"];
    return ListTile(
      leading: Icon(Icons.more_vert), 
      trailing: 
        Text(
          transType == "minus" ? "-$ammount":"+$ammount",
          style: TextStyle( 
            color: transType == "minus" ?  Colors.red:Colors.green,
            fontSize: 15
          ),
        ), 
        title:Text("$name") 
    ); 
  }
  void openDelete(String name,  BuildContext context) async{
    final _formKey = GlobalKey<FormState>();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Are you sure you want to delete your account: $name"),
          content: Builder(
            builder: (context){
              return Container(
                height: 100,
                width: 500,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async{
                          if (_formKey.currentState.validate()) {
                            final response = await http.post("$base/deleteaccount/$_username/$name");
                            final decoded = json.decode(response.body) as Map<String, dynamic>;
                            if(decoded["success"] == "True"){
                              Navigator.of(context).pop();
                              setState(() {
                                accountsList;
                              });
                              _MyHomePageState().build(context);
                            }
                          }
                        },
                        child: Text("Yes"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("No"),
                      )
                    ],
                  ),
                ),
              );
            }
          ),
        );
      },
    );
  }
  void _changeAccount(String account) {
    setState((){
      _account = account;
    });
    (context as Element).reassemble();
  }
  Future<String> _getTotalBalance() async{
    final response = await http.get("$base/gettotalbalance/$_username");
    final decoded = json.decode(response.body) as Map<String,dynamic>;
    String balance = decoded["balance"].toString();
    return formatBalance(balance);
  }
  Future<String> _getBalance(account) async{
    final response = await http.get("$base/getbalance/$_username/$account");
    final decoded = json.decode(response.body) as Map<String,dynamic>;
    String balance = decoded["balance"].toString();
    return formatBalance(balance);
  }
  Future<List> _addTen() async{
    final response = await http.get("$base/getnext/$_username/$_account/$_lastdate");
    final entryList = json.decode(response.body) as List<dynamic>;
    if(_entryList == null){
      _entryList = entryList;
    }
    else{
      for(var i in entryList ){
        _entryList.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Transactions"),
          actions: <Widget>[
            IconButton(
              icon: loggedIn == false ? Icon(Icons.login,color: Colors.white,) : Icon(Icons.logout , color: Colors.white),
              onPressed: (){
                if (loggedIn){
                  _logout();
                }
                else{
                  openLogin(context);
                }
              },
            )
          ]
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
                child: Center(
                  child: FutureBuilder(
                    future: _getTotalBalance(),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                      if(!snapshot.hasData)
                        return new Text(
                          "Balance: \$0.00",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                          );
                      _balanceString = snapshot.data;
                      _balance = double.parse(snapshot.data);
                      return new Text(
                        "Balance: \$$_balanceString",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        )
                      );
                    }
                  )
                ),
              ),
              FutureBuilder(
                future: getAccounts(),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (!snapshot.hasData)
                    return new Container();
                  accountsList = snapshot.data;
                  if (_account == null){
                    _account = accountsList[0];
                    _MyHomePageState().build(context);
                  }
                  return new SizedBox(
                    height: 440,
                    child: ListView.builder(
                      padding: new EdgeInsets.all(6.0),
                      itemCount: accountsList.length,
                      itemBuilder: (BuildContext context, int index){
                        return new GestureDetector(
                          onTap: (){
                            _changeAccount(accountsList[index]);
                          },
                          child : Container(
                            height: 75,
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red),
                              color: accountsList[index] == _account ? Colors.red : Colors.white,
                            ),
                            child: Row(
                              children: <Widget>[
                                FutureBuilder(
                                  future: _getBalance(accountsList[index]),
                                  builder: (BuildContext context, AsyncSnapshot<String> balsnapshot){
                                    if(!balsnapshot.hasData)
                                      return new Text("");
                                    String balance = balsnapshot.data;
                                    return new Expanded(
                                      flex: 8,
                                      child: Text(
                                        '${accountsList[index]} - \$$balance',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: accountsList[index] == _account ? Colors.white : Colors.red,
                                        ),
                                      ),
                                    );
                                  }
                                ),
                                Visibility(
                                  visible : accountsList[index] == _account ? false : true,
                                  child: Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: (){
                                        openDelete(accountsList[index], context);
                                      },
                                    )
                                  )
                                )
                              ]
                            ),
                          )
                        );
                      },
                    )
                  );
                },
              ),
              Visibility(
                visible: _isVisible,
                child: ElevatedButton(
                  onPressed: (){
                    _createNewAccount(context);
                  },
                  child: Text(
                    "Create New Bank Account"
                  )
                )
              ),
              ElevatedButton(
                onPressed: (){
                  changeColor("red");
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(myColors["red"]["primary"]),
                ),
              ),
            ],
          ),
          
        ),
        body: PageView(
          controller: controller,
          children: [
            ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, i) {
                if(_entryList == null){
                  _addTen();
                }
                else if (i >= _entryList.length) {
                  _addTen();
                }
                return _buildRow(i);                    
              }
            ),
            Container(color: Colors.red),
            Container(color: Colors.orange),
            Container(color: Colors.amber),
          ],
          onPageChanged: (index){
            _updatePage(index);
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.book,
                  color: (_pageNum == 0) ? Color(0xFFFF0000) : Color(0xFFaa2222),
                ),
                onPressed: (){
                    _changePage(0);
                }
              ),
              IconButton(
                icon: Icon(
                  Icons.attach_money,
                  color: (_pageNum == 1) ? Color(0xFFFF0000) : Color(0xFFaa2222),
                ),
                onPressed: (){
                    _changePage(1);
                } 
              ),
              FloatingActionButton(
                child: const Icon(
                  Icons.add,
                ),
                onPressed: ()async{
                  accountsList = await getAccounts();
                  if(_username != null){
                    openTransactionForm(context);
                  }
                }
              ),
              IconButton(
                icon: Icon(
                  Icons.addchart, 
                  color: (_pageNum == 2) ? Color(0xFFFF0000) : Color(0xFFaa2222),
                ),
                onPressed: (){
                    _changePage(2);
                } 
              ),
              IconButton(
                icon: Icon(
                  Icons.compare_arrows_rounded, 
                  color: (_pageNum == 3) ? Color(0xFFFF0000) : Color(0xFFaa2222),
                ),
                onPressed: (){
                    _changePage(3);
                } 
              ),
            ],
          ),
          color: const Color(0xFF000000),
        ),
    );
  }
}