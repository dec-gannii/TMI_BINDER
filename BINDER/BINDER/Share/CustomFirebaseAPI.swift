//
//  CustomFirebaseAPI.swift
//  BINDER
//
//  Created by 김가은 on 2022/05/01.
//
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import UIKit

public var linkBtnEmail : String = ""
public var linkBtnSubject : String = ""
public var linkBtnName : String = ""
public var userType : String = ""
public var userEmail : String = ""
public var userName : String = ""
public var userSubject : String = ""
public var userPW : String = ""
public var sharedCurrentPW : String = ""

public var linkBtnIndex : Int = 0
public var varCount: Int = 0

public var sharedEvents : [Date] = []
public var sharedDays : [Date] = []
public var publicTitles: [String] = []

public var varIsEditMode = false

public let db = Firestore.firestore()
public let storage = Storage.storage()
public let storageRef = storage.reference()

