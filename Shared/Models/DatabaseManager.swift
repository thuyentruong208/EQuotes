//
//  Database.swift
//  EQuotes
//
//  Created by Thuyên Trương on 06/09/2022.
//

import Combine
import Firebase

protocol DatabaseManager {
    func create<T: Codable>(_ item: T, in collectionPath: String) -> AnyPublisher<Void, Error>
    func create(_ itemsInCollection: [(items: [[String: Any]], collectionPath: String, documentKey: String?)]) -> AnyPublisher<Void, Error>

    func observeList<T: Decodable>(
        _ dump: T.Type,
        in collectionPath: String,
        order: (by: String, descending: Bool)?) -> AnyPublisher<[T], Error>
    func observeItem<T: Decodable>(
        _ dump: T.Type,
        in collectionPath: String,
        key: String
    ) -> AnyPublisher<T, Error>
    func observeList<T: Decodable>(_ dump: T.Type, keys: [String], in collectionPath: String) -> AnyPublisher<[T], Error>

    func update<T: Codable>(key: String, _ item: T, in collectionPath: String) -> AnyPublisher<Void, Error>

    func delete(_ field: String, isEqualTo: String, in collectionPath: String) -> AnyPublisher<Void, Error>
    func cancelObserveLis(in collectionPath: String)
}

class RealDatabaseManager: DatabaseManager {
    fileprivate let db = Firestore.firestore()
    fileprivate var listeners = [String: ListenerRegistration]()

    func create<T: Codable>(_ item: T, in collectionPath: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] (promise) in
            guard let self = self else { return }
            do {
                _ = try self.db.collection(collectionPath).addDocument(from: item)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func create(_ itemsInCollection: [(items: [[String: Any]], collectionPath: String, documentKey: String?)]) -> AnyPublisher<Void, Error> {

        return Future<Void, Error> { [weak self] (promise) in
            guard let self = self else {
                return
            }

            let batch = self.db.batch()
            for (items, collectionPath, documentKey) in itemsInCollection {
                let collectionRef = self.db.collection(collectionPath)
                items.forEach { data in
                    let documentRef = documentKey == nil ? collectionRef.document() : collectionRef.document(documentKey!)

                    batch.setData(data, forDocument: documentRef)
                }
            }

            batch.commit { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()

    }

    func observeList<T: Decodable>(
        _ dump: T.Type,
        in collectionPath: String,
        order: (by: String, descending: Bool)?)
    -> AnyPublisher<[T], Error> {
        listeners[collectionPath]?.remove()
        let publisher = PassthroughSubject<[T], Error>()

        func handleSnapshot(_ snapshot: QuerySnapshot?, _ error: Error?) {

            if let error = error {
                publisher.send(completion: .failure(error))

            } else if let snapshot = snapshot {
                do {
                    let items: [T] = try snapshot.documents.compactMap {
                        try $0.data(as: T.self)
                    }
                    publisher.send(items)
                } catch {
                    publisher.send(completion: .failure(error))
                }
            }
        }

        let collectionRef = db.collection(collectionPath)
        if let order = order {
            let query = collectionRef
                .order(by: order.by, descending: order.descending)
            listeners[collectionPath] = query.addSnapshotListener(handleSnapshot(_:_:))

        } else {
            listeners[collectionPath] = collectionRef.addSnapshotListener(handleSnapshot(_:_:))
        }

        return publisher.eraseToAnyPublisher()
    }

    func observeItem<T>(_ dump: T.Type, in collectionPath: String, key: String) -> AnyPublisher<T, Error> where T : Decodable {
        listeners[collectionPath + key]?.remove()

        let publisher = PassthroughSubject<T, Error>()

        let documentRef = db.collection(collectionPath)
            .document(key)
        let snapshotListener = documentRef.addSnapshotListener { snapshot, error in

            if let error = error {
                publisher.send(completion: .failure(error))
            } else if let snapshot = snapshot {
                do {
                    let data = try snapshot.data(as: T.self)
                    publisher.send(data)
                } catch {
                    publisher.send(completion: .failure(error))
                }
            }
        }

        listeners[collectionPath + key] = snapshotListener
        return publisher.eraseToAnyPublisher()
    }

    func observeList<T: Decodable>(_ dump: T.Type, keys: [String], in collectionPath: String) -> AnyPublisher<[T], Error> {
        listeners[collectionPath + "keys"]?.remove()
        let publisher = PassthroughSubject<[T], Error>()

        let listener = db.collection(collectionPath)
            .whereField(FieldPath.documentID(), in: keys)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    publisher.send(completion: .failure(error))
                } else if let snapshot = snapshot {
                    do {
                        let items = try snapshot.documents.map {
                            try $0.data(as: T.self)
                        }
                        publisher.send(items)
                    } catch {
                        publisher.send(completion: .failure(error))
                    }

                }
            }

        listeners[collectionPath + "keys"] = listener
        return publisher.eraseToAnyPublisher()
    }

    func update<T: Codable>(key: String, _ item: T, in collectionPath: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] (promise) in
            guard let self = self else { return }
            do {
                _ = try self.db.collection(collectionPath)
                    .document(key)
                    .setData(from: item)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func delete(_ field: String, isEqualTo: String, in collectionPath: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] (promise) in
            guard let self = self else {
                return
            }

            self.db.collection(collectionPath)
                .whereField(field, isEqualTo: isEqualTo)
                .getDocuments(completion: { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        snapshot?.documents.forEach { $0.reference.delete() }
                        promise(.success(()))
                    }
                })


        }
        .eraseToAnyPublisher()

    }

    func cancelObserveLis(in collectionPath: String) {
        listeners[collectionPath]?.remove()
    }
}
