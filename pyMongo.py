import pymongo
from bson import ObjectId
import random
import string
from passlib.hash import pbkdf2_sha256

# Default MongoDB connection string
DEFAULT_STRING = "mongodb://localhost:27017/"

# Required libraries:
# pip install pymongo passlib bson

class MongoDB:
    """
    MongoDB Helper Class to simplify MongoDB operations like insert, fetch, update, delete, etc.
    Supports connection string, database, and collection management.
    """

    def __init__(self, db_name=None, collection_name=None, connection_str=DEFAULT_STRING):
        """
        Initialize MongoDB connection.
        :param db_name: Database name to connect to (optional).
        :param collection_name: Collection name to connect to (optional).
        :param connection_str: MongoDB connection string.
        """
        try:
            self.client = pymongo.MongoClient(connection_str)
            self.db = self.client[db_name] if db_name else None
            self.collection = self.db[collection_name] if collection_name else None
        except Exception as e:
            print(f"Failed to connect to MongoDB: {e}")
            self.client = None

    @staticmethod
    def hashit(data: str) -> str:
        """ Hashes the provided data using pbkdf2_sha256. """
        return pbkdf2_sha256.hash(data)

    @staticmethod
    def verifyHash(password: str, hashed_password: str) -> bool:
        """ Verifies if the password matches the hashed password. """
        return pbkdf2_sha256.verify(password, hashed_password)

    @staticmethod
    def genString(length=15) -> str:
        """ Generates a random alphanumeric string of given length. """
        characters = string.ascii_letters + string.digits
        return ''.join(random.choice(characters) for _ in range(length))

    def addDB(self, db_name: str, collection_name: str):
        """ Switch to a specific database and collection. """
        self.db = self.client[db_name]
        self.collection = self.db[collection_name]

    def getAllDB(self) -> list:
        """ Get a list of all databases. """
        return self.client.list_database_names()

    def getAllCollection(self, db_name=None) -> list:
        """ Get all collections in a given database. Defaults to the current database. """
        db = self.client[db_name] if db_name else self.db
        if db:
            return db.list_collection_names()
        return []

    def insert(self, data: dict) -> bool:
        """ Insert a single document into the collection. """
        try:
            self.collection.insert_one(data)
            return True
        except Exception as e:
            print(f"Insert failed: {e}")
            return False

    def fetch(self, query=None, show_id=False) -> list:
        """
        Fetch documents from the collection based on the query.
        :param query: Dictionary query to filter documents.
        :param show_id: If True, includes '_id' in results.
        """
        result = []
        projection = {"_id": 0} if not show_id else {}
        try:
            documents = self.collection.find(query or {}, projection)
            for doc in documents:
                if show_id and "_id" in doc:
                    doc["_id"] = str(doc["_id"])
                result.append(doc)
            return result[::-1]  # Reverse order
        except Exception as e:
            print(f"Fetch failed: {e}")
            return []

    def count(self, query=None) -> int:
        """ Count the number of documents matching a query. """
        return self.collection.count_documents(query or {})

    def update(self, prev: dict, nxt: dict):
        """
        Update documents in the collection.
        :param prev: Query to find documents to update.
        :param nxt: Data to update.
        """
        try:
            if "_id" in prev:
                prev["_id"] = ObjectId(prev["_id"])
            update_result = self.collection.update_many(prev, {"$set": nxt})
            if update_result.modified_count > 0:
                return True
            return {"message": "Nothing to modify"}
        except Exception as e:
            print(f"Update failed: {e}")
            return False

    def delete(self, query=None) -> bool:
        """
        Delete documents matching a query.
        :param query: Query to filter documents for deletion.
        """
        try:
            if query and '_id' in query:
                query['_id'] = ObjectId(query['_id'])
            delete_result = self.collection.delete_many(query or {})
            return delete_result.deleted_count > 0
        except Exception as e:
            print(f"Delete failed: {e}")
            return False

    def dropDB(self, db_name=None) -> bool:
        """ Drop the specified or current database. """
        try:
            db_to_drop = db_name if db_name else self.db.name
            self.client.drop_database(db_to_drop)
            return True
        except Exception as e:
            print(f"DropDB failed: {e}")
            return False

    def dropCollection(self, collection_name: str) -> bool:
        """ Drop the specified collection. """
        try:
            self.collection.drop() if not collection_name else self.db.drop_collection(collection_name)
            return True
        except Exception as e:
            print(f"DropCollection failed: {e}")
            return False

    def getKeys(self) -> list:
        """ Return the keys (fields) present in the collection. Excludes '_id'. """
        try:
            first_doc = self.collection.find_one()
            if first_doc:
                return [key for key in first_doc.keys() if key != '_id']
        except Exception as e:
            print(f"GetKeys failed: {e}")
        return []

    def close(self):
        """ Close the MongoDB connection. """
        self.client.close()

# Usage Example:
# from mongo_helper import MongoDB
# db = MongoDB("testDB", "testCollection")
# hashed_password = db.hashit("mypassword")
# db.insert({"username": "john_doe", "password": hashed_password})
# print(db.fetch())
