#importing all of the mongo things, date time  and flask to add the date and time to the database items and develope an api
import pymongo
from pymongo import MongoClient
from datetime import datetime


cluster = MongoClient("mongodb+srv://jonahChecketts:Shadow1234@cluster0.fhfqq.mongodb.net/<dbname>?retryWrites=true&w=majority")
db = cluster["users"]
collection = db["collection"]
userList = []

def getUserList():
    global userList
    for user in collection.find():
        userList.append({"username":user["username"],"password":user["password"]})
    return userList

class User:
    userDict = {}
    def __init__(self, name, word):
        self.userDict = {"username" : name, "password" : word}

def userAlreadyExists(username):
    userList = getUserList()
    for user in userList:
        if username == user["username"]:
            return True
    return False

def signUp(name,password,bankname,balance):
    if(not userAlreadyExists(name)):
        userinst = User(name,password).userDict
        collection.insert_one(userinst)
        userList.append(userinst)
        tempdb = cluster[userinst["username"]]
        tempcollection = tempdb[bankname]
        tempcollection.insert_one({"_id": 0 , "balance" : balance})
    else:
        raise Exception("invalid username")