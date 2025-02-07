//
//  ImagePickerManager.swift
//  MyNotes
//
//  Created by Дмитрий Исаев on 05.02.2025.
//

import UIKit
import Photos

class ImagePickerManager {//Создал обертку//Или ImagePickerController?
    
    private weak var viewController: UIViewController? //weak?Сделал что бы задать делегата и для метода present//private?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
}

extension ImagePickerManager {
    
    func openGallery() {//Сделал отдельные методы. Можно одним метом через sourcetype. Но получилось больше кода
        requestPhotoLibraryAccess() //тут проверка норм?
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate//так норм?
        viewController?.present(imagePickerController, animated: true)
    }
    
    func openCamera() {//Сделал отдельные методы. Можно одним метом через sourcetype. Но получилось больше кода
        requestPhotoLibraryAccess()//тут проверка норм?
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate//так норм?
        viewController?.present(imagePickerController, animated: true)
    }
    
    func fetchImageName(info: [UIImagePickerController.InfoKey: Any]) -> String? {//Думаю что имена лучше тут обработать. Nil не обрабатывал
        if let asset = info[.phAsset] as? PHAsset {//так понимаю этот метод сработает если только из галереи фотографии добавлять
            let assetResources = PHAssetResource.assetResources(for: asset)
            guard let fileName = assetResources.first?.originalFilename else { return nil }
            return fileName
        } else {//в другом случае (камера), вернет сгенерированное имя.
            let fileName = "photo_\(Date().timeIntervalSince1970).jpg"//имя задал норм?
            return fileName
        }
    }
    
}

//MARK: - Private methods

private extension ImagePickerManager {
    
    func requestPhotoLibraryAccess() { // сюда убрал данный метод норм?
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: PHAccessLevel.readWrite) { newStatus in
                if newStatus == .authorized {
                    print("Доступ предоставлен.")
                } else {
                    print("Доступ запрещен.")
                }
            }
        case .restricted:
            print("Доступ ограничен.")
        case .denied:
            print("Досуп запрещен.")
        case .authorized:
            print("Доступ уже предоставлен.")
        case .limited:
            print("Доступ ограничен.")
        default:
            print("Неизвестный статус авторизации.")
        }
    }
    
}
