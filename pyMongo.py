#pip3 install pymongo==4.6.0
#pip3 install passlib==1.7.4
import pymongo 
from passlib.hash import pbkdf2_sha256
DEFAULT_STRING= "mongodb://localhost:27017/"
#Syntax for cloud based Connection String
'''client = pymongo.MongoClient("mongodb+srv://<username>:<password>@cluster1.n5hitou.mongodb.net/?retryWrites=true&w=majority")'''


def ping(connectionStr=DEFAULT_STRING):  #Test if the connection Works or Not
    try:
        client = pymongo.MongoClient(connectionStr)
        client.admin.command('ping')
        return True
    except Exception as e:
        # print(f"Connection failed: {e}")
        return False
    finally:
        client.close()
def getAllDB(connectionStr=DEFAULT_STRING):  #List all DB of a Connection
    try:
        client = pymongo.MongoClient(connectionStr)
        database_list = client.list_database_names()
        result = []
        for database in database_list:
            result.append(database) 
        return result
    except Exception as e:
        # print(f"Error: {e}")
        return []
    finally:
        # Close the connection
        client.close() 
def getAllCollection(database_name,connectionStr=DEFAULT_STRING): #List all Collection of a Connection
    try:
        client = pymongo.MongoClient(connectionStr)
        db = client[database_name]
        collections = db.list_collection_names()
        result = []
        for collection in collections:
            result.append(collection) 
        return result
    except Exception as e:
        # print(f"Error: {e}")
        return []
    finally:
        # Close the connection
        client.close()         
def dropDB(database_name,connectionStr=DEFAULT_STRING):  #Delete a DB
    try:
        client = pymongo.MongoClient(connectionStr)
        client.drop_database(database_name)
        return True
    except Exception as e:
        # print(f"Error: {e}")
        return False
    finally:
        client.close()
def dropCollection(collection_name,database_name,connectionStr=DEFAULT_STRING): #Delete A Collection
    try:
        client = pymongo.MongoClient(connectionStr)
        db = client[database_name]
        db.drop_collection(collection_name)
        return True
    except Exception as e:
        # print(f"Error: {e}")
        return False
    finally:
        client.close()
def hashit(data:str):  #hashes any data givent to it
        # Hash the password using Passlib's pbkdf2_sha256
        return pbkdf2_sha256.hash(data)
def verifyHash(password:str, hashedpassword:str):
        return pbkdf2_sha256.verify(password, hashedpassword)
class MongoDB:  #Main Class
    def __init__(self,db_name,collection_name,connectionStr=DEFAULT_STRING):
        self.client = pymongo.MongoClient(connectionStr)
        self.db = self.client[db_name]
        self.collection = self.db[collection_name]
    def insert(self, data={}):
        self.collection.insert_one(data)
        #lst = [data]
        #self.collection.insert_many(lst)
        return True

    def fetch(self,data=None,show_id=False):    
        id = {"_id": 0} if not show_id else {"_id": 1}    
        result = []
        res = self.collection.find(data,id)
        for item in res:
            result.append(item)      
        return result
        
    def count(self,data={}):
        count = self.collection.count_documents(data)
        return count
    
    def update(self,prev,nxt):
        nxt = {"$set":nxt}
        up = self.collection.update_many(prev,nxt)
        count  = up.modified_count
        if count >0:
            return True
        elif count == 0:
            return ({"message":"Nothing To modify"})
        else:
            return False
        
    def delete(self,data={}):
        dlt = self.collection.delete_many(data)
        count = dlt.deleted_count
        if count > 0:
            return True
        else:
            return False  
             
    def close(self):
        self.client.close()

#USAGE EG.
'''
from pyMongo import MongoDB
mydb = MongoDB("db_name","doc_name")
hasedpass = MongoDB.hashit("mypassword")
data = {"name":"d","id":4,"tax":False,"password":hashedpass}
mydb.insert(data)
mydb.fetch()
data = mydb.fetch({"name":"d"})
hashpass = data[0]["password"]
print(mydb.verifyHash("mypassword",hashpass))
'''       
