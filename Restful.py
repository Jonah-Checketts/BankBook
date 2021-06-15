from flask import Flask, jsonify
from flask_restful import Api, Resource
from LoginSystem import *
from datetime import *
from time import strftime
from bankBookDBPostTransactions import *
import pymongo

app = Flask(__name__)
api = Api(app)

#delete the section that says <username> and <password> and replace it with your own username and password for your mongoDB
cluster = MongoClient("mongodb+srv://<username>:<password>@cluster0.fhfqq.mongodb.net/<dbname>?retryWrites=true&w=majority")
db = ''
collection = ''


@app.route("/accounts/<string:username>", methods=['GET'])
def accounts(username):
    validUser = False
    userList = getUserList()
    for user in userList:
        if username == user["username"]:
            validUser = True
            break
    if validUser == True:
        db = cluster[username]
        accountsList = db.list_collection_names()
        formated = {"accounts": accountsList}
        return jsonify(formated)
    else:
        return jsonify({"accounts": "ERROR: USER NOT FOUND"})


@app.route("/signup/<string:username>/<string:password>/<string:account>/<float:initialBalance>", methods=['GET','POST'])
def signup(username,password,account,initialBalance):
    validUser = True
    userList = getUserList()
    for user in userList:
        if username == user["username"]:
            validUser = False
            break
    if validUser == True:
        signUp(username, password, account, initialBalance)
        return jsonify({"success": "True"})
    else:
        return jsonify({"success": "False"})

@app.route("/login/<string:username>/<string:password>", methods=['GET','POST'])
def login(username,password):
    validUser = False
    userList = getUserList()
    for user in userList:
        if user["username"] == username and user["password"] == password:
            validUser = True
            break
    
    if validUser == True:
        return jsonify({"success":"True"})
    else:
        return jsonify({"success":"False"})

@app.route("/newaccount/<string:username>/<string:account>/<float:initialBalance>", methods=['GET','POST'])        
def newaccount(username,account,initialBalance):
    accountsList = []
    validAccount = True
    validUser = False
    if userAlreadyExists(username):
        db = cluster[username]
        validUser = True
    else:
        return jsonify({"success":"False"})
    accountsList = db.list_collection_names()
    for acc in accountsList:
        if acc == account:
            validAccount = False
    if validAccount == True and validUser == True:
        collection = db[account]
        collection.insert_one({"_id": 0, "balance" : initialBalance})
        collection.insert_one({"_id": 1,"initialDate": datetime.now().strftime("%c")})
        return jsonify({"success":"True"})
    else:
        return jsonify({"success":"False"})


@app.route("/gettotalbalance/<string:username>", methods=['GET'])
def gettotalbalance(username):
    totalBalance = 0
    if userAlreadyExists(username):
        db = cluster[username]
        accountsList = db.list_collection_names()
        for account in accountsList:
            collection = db[account]
            balanceItem = collection.find_one({"_id" : 0})
            totalBalance += float(balanceItem["balance"])
        return jsonify({"balance" : str(totalBalance)})
    else:
        return jsonify({"balance" : 0.00})


@app.route("/getbalance/<string:username>/<string:account>", methods=['GET'])
def getbalance(username,account):
    if userAlreadyExists(username):
        db = cluster[username]
        collection = db[account]
        return collection.find_one({"_id" : 0})
    else:
        return jsonify({"balance" : 0.00})

@app.route("/deleteaccount/<string:username>/<string:account>", methods=['GET','POST'])
def deleteaccount(username,account):
    worked = deleteAccount(username, account)
    if worked == True:
        return jsonify({"success" : "True"})
    else:
        return jsonify({"success" : "False"})

@app.route("/newentry/single/<string:username>/<string:account>/<string:ptype>/<string:name>/<float:ammount>", methods=['POST'])
def newEntry(username,account,ptype,name,ammount):
    if(ptype == "Payment"):
        entry = Entry(name,ammount,ptype,"minus", datetime.now().strftime("%c"))
        enter(username,account,entry,"minus")
    else:
        entry = Entry(name,ammount,ptype,"minus", datetime.now().strftime("%c"))
        enter(username,account,entry,"plus")
    return "sent"

@app.route("/transfer/<string:username>/<string:account1>/<account2>/<string:name>/<float:ammount>", methods=['POST'])
def Transfer(username,account1,account2,name,ammount):
    entry1 = Entry(name,ammount,"Transfer","plus", datetime.now().strftime("%c"))
    entry2 = Entry(name,ammount,"Transfer","minus", datetime.now().strftime("%c"))
    enter(username,account1,entry1,"plus")
    enter(username,account2,entry2,"minus")
    return "sent"

@app.route("/getnext/<string:username>/<string:account>/<string:lastdate>", methods=['GET'])
def getNext(username,account,lastdate):
    db = cluster[username]
    collection = db[account]
    entryList = []
    currentDate = datetime.min
    if(lastdate == "none"):
        initial = getLastDate(username,account)
        initialDate = initial["initialDate"]
        currentDate = datetime.strptime(initialDate,"%c")
    else:
        currentDate = datetime.strptime(lastdate, "%c")
    while len(entryList) == 0:
        currentDate += timedelta(days=1)
        entries = []
        for document in collection.find({"date":currentDate}):
            entries.append(document)
        sortedEntries = sortEntries(entries)
        for entry in sortedEntries:
            entryList.append(entry)
    print(entryList[0]["name"])
    return jsonify([{"name":"Hello","ammount":5.00,"pt":"minus"},{"name":"Hello","ammount":5.00,"pt":"plus"}])

@app.route("/")
def default():
    return ("ERROR: command input not found")


if __name__ == "__main__":
    app.run(debug=True)
