#importing all of the mongo things and date time to add the date and time to the database items
import pymongo
from pymongo import MongoClient
from datetime import datetime
from flask import Flask
from flask_restful import Api, Resource
from LoginSystem import *
from hashlib import sha256

#database variables
cluster = MongoClient("mongodb+srv://jonahChecketts:Shadow1234@cluster0.fhfqq.mongodb.net/<dbname>?retryWrites=true&w=majority")
db = cluster["none"]
collection = db["none"]

def setDbVars(username,account):
    global db
    global collection
    db = cluster[username]
    collection = db[account]
#find the largest entry id then create the new one in numerical order
def getNextEntryId():
    biggest = 1
    id = 2
    running = True

    while running == True:
        x = collection.find_one({"_id": id})
        try:
            if x["_id"] > biggest:
                biggest = x["_id"]
            id = id + 1
        except:
            return biggest + 1
            running = False

#create a dictionary that is structured correctly for the database
class Entry:
    global inc
    itemDict = {}
    def __init__(self, name, ammount, pn, pt, date):
        self.itemDict = {"_id": getNextEntryId(), "name": name,"ammount": ammount, "pn": pn, "pt": pt, "date": date}

#put your entry into the database
def enter(username,account,entry,pm):
    setDbVars(username,account)
    collection.insert_one(entry.itemDict)
    balanceItem = collection.find_one({"_id" : 0})
    balanceNum = float(balanceItem["balance"])
    if(pm == "plus"):
        balanceNum += entry.itemDict["ammount"]
    else:
        balanceNum -= entry.itemDict["ammount"]
    collection.delete_one({"_id":0})
    collection.insert_one({"_id":0,"balance":balanceNum})


#sorts a list of entries by date in decending order
def sortEntries(entries):
    for i in range(len(entries)):
        maxid = i
        for j in range(i+1, len(entries)):
            if entries[maxid]["date"] < entries[j]["date"]:
                maxid = j
        entries[i], entries[maxid] = entries[maxid], entries[i]
    return entries

#get an entry through any of the keys and values you can get from the front end
def getEntry(**kwargs):
    kwargDict = {}
    for key,value in kwargs.items():
        kwargDict[key] = value     
    return collection.find_one(kwargDict)

#get rid of an entry in the database
def deleteEntry(**kwargs):
    kwargDict = {}
    for key,value in kwargs.items():
        kwargDict[key] = value
    collection.delete_one(kwargDict)
    print(str(kwargDict) + ": deleted successfully")

def getLastDate(username, account):
    setDbVars(username,account)
    return collection.find_one({"_id":1})

def deleteAccount(username, account):
    setDbVars(username, account)
    accountsList = db.list_collection_names()
    if account in accountsList:
        db[account].drop()
        return True
    else:
        return False

def deleteDB(username, password):
    print("deleting your profile...")
    cluster.drop_database(username)
    cluster["users"]["collection"].delete_one({"username" : username, "password" : password})