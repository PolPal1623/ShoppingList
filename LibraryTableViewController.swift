//
//  LibraryTableViewController.swift
//  ShoppingList
//
//  Created by Polynin Pavel on 26.01.16.
//  Copyright © 2016 Polynin Pavel. All rights reserved.
//

import UIKit
import RealmSwift

// Класс GroceriesLibraryRealm для объектов хранимых в памяти

class GroceriesLibraryRealm: Object {
  
  dynamic var name: String = "" // Название продукта
  
  dynamic var raiting: Double = 0 // Рейтинг продукта
  
  dynamic var countQueries: Int = 1 // Количество вызовов продукта
  
  dynamic var mass: Double = 0 // Масса продукта
}

// Класс LibraryTableViewControlle библиотека для хранения продуктов

class LibraryTableViewController: UITableViewController {
  //===================================//
  // MARK: - Глобальные переменные для LibraryTableViewController
  //===================================//
  
    var listProduct: Results<(GroceriesLibraryRealm)>! // Массив продуктов в библиотеке
  
    var tableHeaderHeight: CGFloat = 120.0 // Величина максимального растягивания imageView при свайпе вниз
  
    var headerMaskLayer: CAShapeLayer! // Переменная для анимации растягивания
  
    let sortingListProduct = realm.objects(GroceriesLibraryRealm).sorted("name") //Сортировка списка listProduct по имени
  
    let backgroundColor = UIColor(red: 170/255, green: 0, blue: 157/255, alpha: 1) // Цвет фона и ячеек
  
  //===================================//
  // MARK: - IBOutlet связывающие Scene и LibraryTableViewController
  //===================================//
  
    @IBOutlet weak var headerView: UIView! // View над таблицей со списком покупок
  
    @IBOutlet weak var imageLibrary: UIImageView! // Image на экране над списком
  
    @IBOutlet weak var bottomView: UIView! // View под таблицей для удаления лишних разделителей
  
  //===================================//
  // MARK: - IBAction на нашей Scene
  //===================================//
  
  //-----------------------------------// Button add new product in library
    @IBAction func addNewProductInLibrary(sender: UIButton) {
    
      //------------------ Создаем AlertController при нажатии на addButtonBar
        let alert = UIAlertController(title: "Новый продукт", message: "Впишите название и массу продукта в КГ (только цифры)", preferredStyle: .Alert)
      
        alert.addTextFieldWithConfigurationHandler { (UITextField) -> Void in } // Добавляем текстовое поле в AlertController
        alert.addTextFieldWithConfigurationHandler { (UITextField) -> Void in } // Добавляем текстовое поле в AlertController
      
      //------------------ Дизайн textFields
        alert.textFields?.first!.backgroundColor = UIColor(red: 170/255, green: 0, blue: 157/255, alpha: 0.2)
        alert.textFields?.first!.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 23)
        alert.textFields?.first!.placeholder = "Название"
        alert.textFields?[1].backgroundColor = UIColor(red: 170/255, green: 0, blue: 157/255, alpha: 0.2)
        alert.textFields?[1].font = UIFont(name: "AppleSDGothicNeo-Thin", size: 23)
        alert.textFields?[1].placeholder = "Масса"
      
      
      //------------------ AlertAction for AlertController
        let saveAction = UIAlertAction(title: "Сохранить", style: .Default) { (action: UIAlertAction) -> Void in
          
          let nameTextField = alert.textFields?.first // Текстовое поле в alert
          
          let massTextField = alert.textFields?[1] // Текстовое поле в alert
        
          let product = GroceriesLibraryRealm() // Константа типа GroceriesLibraryRealm() для записи в память
          
          product.name = (nameTextField?.text)! // Имя продута присвоено из текстового поля
          
          //------------------ Условие ввода слишком длинного названия
          if nameTextField?.text?.characters.count <= 22 {
          
          //------------------ Условие ввода не числа в строку масса
          if let mass = Double((massTextField?.text)!) {
          
            product.mass = mass
          
            //------------------ Условие повторного ввода имени продукта
            if let repeatName = realm.objects(GroceriesLibraryRealm).filter("name == %@", product.name).first {
            
            //------------------ Создаем AlertController при ошибке повтор имени
            let errorAlert = UIAlertController(title: "Повтор имени", message: "Название \(repeatName.name) уже существует", preferredStyle: .ActionSheet)
            
            //------------------ AlertAction for AlertController
            let backAction = UIAlertAction(title: "Вернуться", style: .Cancel) { (action: UIAlertAction) -> Void in }
            
            errorAlert.addAction(backAction) // AlertAction добавляем в AlertController
            
            self.presentViewController(errorAlert, animated: true, completion: nil) // добавляем AlertController на View Controller
  
          } else {
          
        //------------------ Сохранение через Realm
          try! realm.write { realm.add(product) }
          
          self.updateListLibrary() // Метод для перезаписи списка и перезагрузки таблицы
        
        }
            
          } else {
            
            //------------------ Создаем AlertController при ошибке повтор имени
            let errorAlert = UIAlertController(title: "Ошибка с массой", message: "Масса должна содержать только числовые значения, а в качестве разделителя дробной и целой части используйте точку", preferredStyle: .ActionSheet)
            
            //------------------ AlertAction for AlertController
            let backAction = UIAlertAction(title: "Вернуться", style: .Cancel) { (action: UIAlertAction) -> Void in self.presentViewController(alert, animated: true, completion: nil)}
            
            errorAlert.addAction(backAction) // AlertAction добавляем в AlertController
            
            self.presentViewController(errorAlert, animated: true, completion: nil) // добавляем AlertController на View Controller
            
          }
            
          } else {
            
            //------------------ Создаем AlertController при ошибке повтор имени
            let errorAlert = UIAlertController(title: "Длина названия", message: "Название должно содержать от 1 до 22 символов. Твое название состоит из \((nameTextField?.text?.characters.count)!) символов", preferredStyle: .ActionSheet)
            
            //------------------ AlertAction for AlertController
            let backAction = UIAlertAction(title: "Вернуться", style: .Cancel) { (action: UIAlertAction) -> Void in self.presentViewController(alert, animated: true, completion: nil)}
            
            errorAlert.addAction(backAction) // AlertAction добавляем в AlertController
            
            self.presentViewController(errorAlert, animated: true, completion: nil) // добавляем AlertController на View Controller
            
          }
          
      }

      //------------------ AlertAction for AlertController
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action: UIAlertAction) -> Void in }
      
        alert.addAction(saveAction) // AlertAction добавляем в AlertController
        alert.addAction(cancelAction) // AlertAction добавляем в AlertController
      
        self.presentViewController(alert, animated: true, completion: nil) // добавляем AlertController на View Controller
    
    }
  
  //===================================//
  // MARK: - Методы загружаемые перед или после обновления View Controller
  //===================================//

  //-----------------------------------// Метод viewDidLoad срабатывает при загрузке View Scene
    override func viewDidLoad() {
    
    //------------------ Перенос всех свойств класса этому экземпляру
      super.viewDidLoad()
      
      self.updateListLibrary() // Метод для перезаписи списка и перезагрузки таблицы
      
      //------------------ Настройка дизайна
      // tableView.separatorStyle = .None // Убрать линиия разделения ячеек
      tableView.backgroundColor = backgroundColor
      imageLibrary.image = UIImage(named: "BirdNew") // Картинка над таблицей
      imageLibrary.backgroundColor = UIColor(red: 74/255, green: 10/255, blue: 86/255, alpha: 1) // Цвет над таблицей
      bottomView.backgroundColor = tableView.backgroundColor // Цвет View под таблицей

      //------------------ Растягивание при свайпе вниз
      headerView = tableView.tableHeaderView
      
      tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      
      tableView.contentOffset = CGPoint(x: 0, y: 0)
      
      headerMaskLayer = CAShapeLayer()
      headerMaskLayer.fillColor = UIColor.blackColor().CGColor
      headerView.layer.mask = headerMaskLayer
      
      updateHeaderView()
  }
  
  //-----------------------------------// Метод viewWillAppear срабатывает при изменении интерфейса
    override func viewWillAppear(animated: Bool) {
    
    //------------------ Перенос всех свойств класса этому экземпляру
    super.viewWillAppear(animated)
    
  }
  
  //-----------------------------------// Метод для работы анимации растягивания
    override func viewWillLayoutSubviews() {
    
    super.viewWillLayoutSubviews()
    
    updateHeaderView()
    
  }
  
  //-----------------------------------// Метод для работы анимации растягивания
    override func viewDidLayoutSubviews() {
    
    super.viewDidLayoutSubviews()
    
    updateHeaderView()
    
  }
  
  //-----------------------------------// Метод для работы анимации растягивания и перехода на другой экран
    override func scrollViewDidScroll(scrollView: UIScrollView) {
    
    updateHeaderView()
    
    let offsetY = scrollView.contentOffset.y
    
    let argument: CGFloat = -40.0
    
    if (-offsetY) > (tableHeaderHeight + argument) {
     
      self.dismissViewControllerAnimated(true, completion: nil)
      
    }
    
  }
  
  //-----------------------------------// Метод для изменения цвета статус бара
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  //===================================//
  // MARK: - Кастомные методы
  //===================================//
  
  //-----------------------------------// Метод для перезаписи списка и перезагрузки таблицы
    func updateListLibrary() {
    
    self.listProduct = try! Realm().objects(GroceriesLibraryRealm)
    
    self.tableView.reloadData()
    
  }
  
  //-----------------------------------// Метод для анимации растягивания
    func updateHeaderView() {
    
    var headerRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableHeaderHeight)
    
    if tableView.contentOffset.y < -0.2*tableHeaderHeight {
      
      headerRect.origin.y = tableView.contentOffset.y
      headerRect.size.height = -5*tableView.contentOffset.y
      
    }
    
    headerView.frame = headerRect
    
    let path = UIBezierPath()
    path.moveToPoint(CGPoint(x: 0, y: 0))
    path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
    path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height))
    path.addLineToPoint(CGPoint(x: 0, y: headerRect.height))
    headerMaskLayer?.path = path.CGPath
    
    
  }

  
  //===================================//
  // MARK: - Методы для работы и настройки TableView
  //===================================//

  //-----------------------------------// Метод возвращает кол-во секций TableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      
      return 1
      
    }

  //-----------------------------------// Метод возвращает кол-во строк в секции TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      //------------------ Условия присутствия элементов в списке
      if let countList = self.listProduct {
        
        return countList.count
      }
      
      return 0
      
    }
  
  //-----------------------------------// Метод для работы и настройки Cell в TableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   
      //------------------ Создаем ячейку по идентификатору с indexPath в методе для работы и настройки Cell в TableView
      let cell = tableView.dequeueReusableCellWithIdentifier("LibraryCell", forIndexPath: indexPath) as! LibraryTableViewCell
      
      cell.nameProductInLibrary.text = sortingListProduct[indexPath.row].name // Перебор имен продуктов для создание списка
      
      cell.backgroundColor = tableView.backgroundColor
  
      return cell
      
    }
  
  //-----------------------------------// Метод для работы cо свайпом ячейки. Стандартные кнопки (без нее свайпа нет)
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
    
  }
  
  //-----------------------------------// Метод для работы с действиями по свайпу ячейки
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    
      //------------------ Действия при нажатии кнопки "Удалить"
      let delete = UITableViewRowAction(style: .Default, title: "Удалить ") {(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
        
       let product = self.sortingListProduct[indexPath.row] // Объект в выбранной ячейке для его удаления
        
        //------------------ Удаление через Realm
        try! realm.write { realm.delete(product) }
        
        self.updateListLibrary() // Метод для перезаписи списка и перезагрузки таблицы
      
      }
      
      delete.backgroundColor = UIColor(red: 243/255, green: 76/255, blue: 255/255, alpha: 1)
    
      //------------------ Действия при нажатии кнопки "Купить"
      let action = UITableViewRowAction(style: .Default, title: "Купить  ") {(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
        
        let product = self.sortingListProduct[indexPath.row] // Объект в выбранной ячейке
        
        let productForShopping = ShoppingListRealm() // Константа типа ShoppingListRealm() для записи в память
        
        if let repeatName = realm.objects(ShoppingListRealm).filter("name == %@", product.name).first {
          
          //------------------ Создаем AlertController при ошибке повтор имени
          let errorAlert = UIAlertController(title: "Повтор наименования", message: "\(repeatName.name) уже в списке покупок", preferredStyle: .ActionSheet)
          
          //------------------ AlertAction for AlertController
          let backAction = UIAlertAction(title: "Вернуться", style: .Cancel) { (action: UIAlertAction) -> Void in }
          
          errorAlert.addAction(backAction) // AlertAction добавляем в AlertController
          
          self.presentViewController(errorAlert, animated: true, completion: nil) // добавляем AlertController на View Controller
          
        } else {
        
        //------------------ Перенос всех свойств выбранного в библиотеке объекта объекту типа ShoppingListRealm()
        productForShopping.name = product.name
        
        productForShopping.raiting = product.raiting
        
        productForShopping.countQueries = product.countQueries
        
        productForShopping.mass = product.mass
        
        //------------------ Сохранение объекта через Realm
        try! realm.write { realm.add(productForShopping) }
          
        }
        
        tableView.reloadData() // Перезагрузка таблицы спасает от зависания на кнопках выбора
      
      }
      
      action.backgroundColor = UIColor(red: 161/255, green: 88/255, blue: 211/255, alpha: 1)
      
      //------------------ Действия при нажатии кнопки "Изменить"
      let change = UITableViewRowAction(style: .Default, title: "Изменить ") {(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
       
        let product = self.sortingListProduct[indexPath.row] // Объект в выбранной ячейке
        
        //------------------ Извлекаем этот объект из памяти
        if let changeProduct = realm.objects(GroceriesLibraryRealm).filter("name == %@", product.name).first {
          
          //------------------ Создаем AlertController при нажатии на addButtonBar
          let alert = UIAlertController(title: "Изменить параметры", message: "Впишите новое название и/или массу продукта в КГ (только цифры)", preferredStyle: .Alert)
          
          alert.addTextFieldWithConfigurationHandler { (UITextField) -> Void in } // Добавляем текстовое поле в AlertController
          alert.addTextFieldWithConfigurationHandler { (UITextField) -> Void in } // Добавляем текстовое поле в AlertController
          
          //------------------ Дизайн textFields
          alert.textFields?.first!.backgroundColor = UIColor(red: 170/255, green: 0, blue: 157/255, alpha: 0.2)
          alert.textFields?.first!.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 23)
          alert.textFields?.first!.text = changeProduct.name
          alert.textFields?.first!.placeholder = "Название"
          alert.textFields?[1].backgroundColor = UIColor(red: 170/255, green: 0, blue: 157/255, alpha: 0.2)
          alert.textFields?[1].font = UIFont(name: "AppleSDGothicNeo-Thin", size: 23)
          alert.textFields?[1].placeholder = "Масса"
          
          
          //------------------ AlertAction for AlertController
          let changeAction = UIAlertAction(title: "Изменить", style: .Default) { (action: UIAlertAction) -> Void in
            
            let nameTextField = alert.textFields?.first // Текстовое поле в alert
            
            let massTextField = alert.textFields?[1] // Текстовое поле в alert
            
            //------------------ Условие ввода слишком длинного названия или короткого назавания
            if nameTextField?.text?.characters.count <= 22 && nameTextField?.text != "" {
              
              //------------------ Условие ввода не числа в строку масса
              if let mass = Double((massTextField?.text)!) {
                
                //------------------ Условие ввода уникального назавания
                if !((nameTextField?.text)! == realm.objects(GroceriesLibraryRealm).filter("name == %@", (nameTextField?.text)!).first?.name) || (nameTextField?.text)! == changeProduct.name {
                  
                  //------------------ Условие наличия этого объекта в списке покупок в данный момент
                  if let shoppingListproduct = realm.objects(ShoppingListRealm).filter("name == %@", product.name).first {
                    
                    //------------------ Удаление через Realm из listShopping
                    try! realm.write { realm.delete(shoppingListproduct) }
                    
                  }
                  
                  //------------------Обновление информации о продукте в listShopping
                  try! realm.write {
                    
                    changeProduct.name = (nameTextField?.text)!
                    
                    changeProduct.mass = mass
                    
                  }
                  
                  self.updateListLibrary() // Метод для перезаписи списка и перезагрузки таблицы
                  
                } else {
                  
                  //------------------ Создаем AlertController при ошибке повтор имени
                  let errorAlert = UIAlertController(title: "Повтор имени", message: "Название уже существует", preferredStyle: .ActionSheet)
                  
                  //------------------ AlertAction for AlertController
                  let backAction = UIAlertAction(title: "Вернуться", style: .Cancel) { (action: UIAlertAction) -> Void in self.presentViewController(alert, animated: true, completion: nil)}
                  
                  errorAlert.addAction(backAction) // AlertAction добавляем в AlertController
                  
                  self.presentViewController(errorAlert, animated: true, completion: nil) // добавляем AlertController на View Controller
                  
                }
                
              } else {
                
                //------------------ Создаем AlertController при ошибке повтор имени
                let errorAlert = UIAlertController(title: "Ошибка с массой", message: "Масса должна содержать только числовые значения, а в качестве разделителя дробной и целой части используйте точку", preferredStyle: .ActionSheet)
                
                //------------------ AlertAction for AlertController
                let backAction = UIAlertAction(title: "Вернуться", style: .Cancel) { (action: UIAlertAction) -> Void in self.presentViewController(alert, animated: true, completion: nil)}
                
                errorAlert.addAction(backAction) // AlertAction добавляем в AlertController
                
                self.presentViewController(errorAlert, animated: true, completion: nil) // добавляем AlertController на View Controller
                
              }
              
            } else {
              
              //------------------ Создаем AlertController при ошибке повтор имени
              let errorAlert = UIAlertController(title: "Длина названия", message: "Название должно содержать от 1 до 22 символов. Твое название состоит из \((nameTextField?.text?.characters.count)!) символов", preferredStyle: .ActionSheet)
              
              //------------------ AlertAction for AlertController
              let backAction = UIAlertAction(title: "Вернуться", style: .Cancel) { (action: UIAlertAction) -> Void in self.presentViewController(alert, animated: true, completion: nil)}
              
              errorAlert.addAction(backAction) // AlertAction добавляем в AlertController
              
              self.presentViewController(errorAlert, animated: true, completion: nil) // добавляем AlertController на View Controller
              
            }
                  
          }
          
          //------------------ AlertAction for AlertController
          let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (action: UIAlertAction) -> Void in
          
          self.updateListLibrary() // Метод для перезаписи списка и перезагрузки таблицы
            
          }
          
          alert.addAction(changeAction) // AlertAction добавляем в AlertController
          alert.addAction(cancelAction) // AlertAction добавляем в AlertController
          
          self.presentViewController(alert, animated: true, completion: nil) // добавляем AlertController на View Controller
          
        }
        
      }
      
      change.backgroundColor = UIColor(red: 80/255, green: 88/255, blue: 211/255, alpha: 1)
    
      return [action, change, delete]
    
  }
  
  //-----------------------------------// Метод определяющий действия при нажатии на ячейку
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  tableView.deselectRowAtIndexPath(indexPath, animated: true) // Убирает анимацию залипания при нажатия(выбора ячейки)
    
  }
  
  //===================================//
  // MARK: - Методы которые в данный момент не используются
  //===================================//
  
  //-----------------------------------// Метод срабатывает при заполнении памяти у приложения
  override func didReceiveMemoryWarning() {
    
    //------------------ Перенос всех свойств класса этому экземпляру
    super.didReceiveMemoryWarning()
    
    print("ERROR: Память переполнена") // Предупреждение для разработчика
    
  }

}
