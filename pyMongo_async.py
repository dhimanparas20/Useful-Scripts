from bson import ObjectId
import pymongo
import random
import string 
from passlib.hash import pbkdf2_sha256
DEFAULT_STRING= "mongodb://mongo:27017/"

"""
This class is used to interact with the database.
Requirements : pymongo==4.6.0 , passlib
"""

async def hashit(data:str)->str:  
        """hashes any data givent to it"""
        # Hash the password using Passlib's pbkdf2_sha256
        return pbkdf2_sha256.hash(data)
async def verifyHash(password:str, hashedpassword:str)->bool:
        """
        verifies hashed password
        - `password` :  unhashed password
        - `hashedpassword` : hashed password
        """
        return pbkdf2_sha256.verify(password, hashedpassword)
async def genString(length:int=15)->str:
    """generates random string of given length"""
    characters = string.ascii_letters + string.digits
    random_string = ''.join(random.choice(characters) for _ in range(length))
    return random_string

class MongoDB:  #Main Class
    def __init__(self,db_name:str,collection_name:str,connectionStr=DEFAULT_STRING)->bool:     
        """
        Connect to string
        Return True If Connection Successful
        """
        try: 
            self.client = pymongo.MongoClient(connectionStr)
            if db_name and collection_name:
                self.db = self.client[db_name]
                self.collection = self.db[collection_name]
                return True
        except:
            return False       

    async def addDB(self,db_name:str, collection_name:str)->bool:
        """ 
            Use specififc DB and Collection.
            Return True If Successful.
        """
        try:
            self.db = self.client[db_name]
            self.collection = self.db[collection_name]  
            return True
        except:
            return False
        
    async def getAllDB(self)->list:
        """Get list of all DB of The Current Object String."""
        try:    
            database_list = self.client.list_database_names()
            return database_list 
        except Exception as e:
            print(f"getAllDB Exception: {e}")
            return []

    async def getAllCollection(self,db_name:str=None)->list:
        """Get list of Collection names of a DB"""
        if db_name:
            db = self.client[db_name]
        else:
            db = self.client[self.db]    
        try:    
            collections = db.list_collection_names()
            return collections   
        except Exception as e:
            print(f"getAllCollection Exception: {e}")
            return []

    async def insert(self, data:dict={})->bool:
        """Insert Single Data to Collection"""
        try:
            self.collection.insert_one(data)
            #lst = [data]
            #self.collection.insert_many(lst)
            return True
        except Exception as e:
            print(f"insert Exception: {e}")
            return False

    async def insert_many(self, data:dict={})->bool:
        """Insert Multiple Data to Collection"""
        try:
            lst = [data]
            self.collection.insert_many(lst)
            return True
        except Exception as e:
            print(f"insert_many Exception: {e}")
            return False    

    async def fetch(self, data:dict=None, show_id:bool=False)->list: 
        """Fetch data from collection"""
        result = []
        projection = {"_id": 0} if show_id == False else {}
        res = self.collection.find(data, projection)

        for item in res:
            if show_id and "_id" in item:
                # Convert _id to string format if show_id is True
                item["_id"] = str(item["_id"])

                # Insert _id at the beginning of keys and values
                ordered_item = {"_id": item["_id"]}
                ordered_item.update(item)
                result.append(ordered_item)
            else:
                result.append(item)

        result.reverse()
        return result

    async def count(self,data:dict={})->int:
        """Counts total no of documents in a Collection"""
        try:
            count = self.collection.count_documents(data)
            return count  
        except Exception as e:
            print(f"count Exception: {e}")
            return 0    

    async def update(self, prev:dict, nxt:dict)->int:
        """
        Updates existing data to newer values.
        Need atlest one PrimaryKey/Unique Value in `prev` parameter.
        Returns the count of data changed
        """  
        #Check if "_id" is in prev and convert it to ObjectId
        if "_id" in prev:
            prev["_id"] = ObjectId(prev["_id"])
        nxt = {"$set": nxt}
        up = self.collection.update_many(prev, nxt)
        count = up.modified_count
        
        if count > 0:
            return count
        else:
            print("Nothing To modify")
            return 0

    async def delete(self,data:dict={})->int:
        """
        Deletes Data
        Needs a PrimaryKey/Unique Value in data.
        Returns count of items deleted.
        """
        if '_id' in data and isinstance(data['_id'], str):
            data['_id'] = ObjectId(data['_id'])
        dlt = self.collection.delete_many(data)
        count = dlt.deleted_count
        if count > 0:
            return count
        else:
            return 0  

    async def dropDB(self,db_name:str=None)->bool:
        """Drops a Database"""
        try:
            if db_name:
                self.client.drop_database(db_name)
            else:
                if self.db:
                    self.client.drop_database(self.db) 
                else:
                    return False          
            return True
        except Exception as e:
            print(f"dropDB Exception: {e}")
            return False

    async def dropCollection(self,collection_name:str=None,db_name:str=None,)->bool:
        """Drops a Collection"""
        try:
            db =None
            if collection_name and not db_name:
                db = self.client[self.db]
                
            if db_name and collection_name:
                db = self.client[db_name]
            
            db.drop_collection(collection_name)        
            return True
        except Exception as e:
            print(f"dropCollection Exception: {e}")
            return False               

    async def getKeys(self,exclude_id:bool=True)->list:
        """Gets list of keys inside the collection"""
        try:
            keys = list(self.collection.find_one().keys())
            if exclude_id: # Exclude '_id' from the list
                keys.remove('_id')  
            return keys
        except:
            return ([None])

    async def close(self)->bool: 
        """Closes the MongoDB Client"""
        try:
            self.client.close()
        except Exception as e:
            print (f"close Exception: {e}")    
            return False

#Usage
'''
mydb = MongoDB("AutomationBOT","bot")
async def main():  
    data = {"uid":"d","token":4}
    print(await mydb.insert(data))
    print(await (mydb.fetch()))

if __name__ == "__main__":
    asyncio.run(main())    
'''    
