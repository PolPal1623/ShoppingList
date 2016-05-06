//
//  ShoppingTableViewController.swift
//  ShoppingList
//
//  Created by Polynin Pavel on 26.01.16.
//  Copyright © 2016 Polynin Pavel. All rights reserved.
//

import UIKit
import RealmSwift

// Класс ShoppingListRealm для объектов хранимых в памяти

class ShoppingListRealm: Object {
  
  dynamic var name: String = "" // Название продукта
  
  dynamic var raiting: Double = 0 // Рейтинг продукта
  
  dynamic var countQueries: Int = 1 // Количество вызовов продукта
  
  dynamic var mass: Double = 0 // Масса продукта
}


// Класс LibraryTableViewControlle библиотека для хранения продуктов

class ShoppingTableViewController: UITableViewController {
  
  //===================================//
  // MARK: - Глобальные переменные для LibraryTableViewController
  //===================================//
  
  var listShopping: Results<(ShoppingListRealm)>! // Массив продуктов в списке покупок
  
  var tableHeaderHeight: CGFloat = 120.0 // Величина максимального растягивания imageView при свайпе вниз
  
  var headerMaskLayer: CAShapeLayer! // Переменная для анимации растягивания
  
  let sortingListShopping = realm.objects(ShoppingListRealm).sorted("raiting") //Сортировка списка listShopping по рейтингу
  
  var red: CGFloat = 20 // Цвет
  
  let green: CGFloat = 20 // Цвет
  
  var blue: CGFloat = 200 // Цвет
  
  //===================================//
  // MARK: - IBOutlet связывающие Scene и ShoppingTableViewController
  //===================================//
  
  @IBOutlet weak var headerView: UIView! // View над таблицей со списком покупок
  
  @IBOutlet weak var imageShoppingScrene: UIImageView! // Изображение над таблицей со списком покупок
  
  @IBOutlet weak var buttonForSegua: UIButton! // Кнопка для перехода на другой экран
  
  @IBOutlet weak var bottomView: UIView! // View под таблицей для удаления лишних разделителей 
  
  @IBOutlet weak var massLabel: UILabel! // Label с массой продукта 
  
  //===================================//
  // MARK: - Методы загружаемые перед или после обновления View Controller
  //===================================//
  
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
      
     buttonForSegua.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
      
    }
    
  }

  //-----------------------------------// Метод viewDidLoad срабатывает при загрузке View Scene
  override func viewDidLoad() {
    
    //------------------ Перенос всех свойств класса этому экземпляру
    super.viewDidLoad()
    
    self.updateListLibrary() // Метод для синхронизации списка с памятью и перезагрузки таблицы
    
    self.massInListShopping(&self.red, blue: &self.blue) // Подсчет массы покупок
    
    //------------------ Настройка дизайна
    //tableView.separatorStyle = .None // Убрать линиия разделения ячеек
    imageShoppingScrene.image = UIImage(named: "RocetNew") // Картинка над таблицей
    
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
    
    updateListLibrary() // Метод для синхронизации списка с памятью и перезагрузки таблицы
    
    self.massInListShopping(&self.red, blue: &self.blue) // Подсчет массы покупок
    
  }
  
  //-----------------------------------// Метод для изменения цвета статус бара
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  //===================================//
  // MARK: - Кастомные методы
  //===================================//

  //-----------------------------------// Метод для синхронизации списка с памятью и перезагрузки таблицы
  func updateListLibrary() {
    
    self.listShopping = try! Realm().objects(ShoppingListRealm)
    
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
  
  //-----------------------------------// Подсчет массы покупок и цвета фона
  func massInListShopping(inout red: CGFloat, inout blue: CGFloat) {
    
    var allMassInListShopping: Double = 0 // Масса всех покупок
    
    //----------------- Подсчет массы покупок
    for var i = 0; i < sortingListShopping.count; i++ {
      
      let massInListShopping = self.sortingListShopping[i].mass
      
      allMassInListShopping += massInListShopping
      
    }
    
    massLabel.text = "\(allMassInListShopping) Кг"
    
    //----------------- Условия изменения цвета
    var smallred: CGFloat = 20 // Цвет
    
    var smallblue: CGFloat = 200 // Цвет
    
    if allMassInListShopping <= 5.0 {
      
      smallred = CGFloat(Int(20 + 36*allMassInListShopping)) // Цвет
      
      smallblue = CGFloat(Int(200 - 36*allMassInListShopping)) // Цвет
      
    } else {
      
      smallred = 200 // Цвет
      
      smallblue = 20 // Цвет
      
    }
    
    red = smallred
    
    blue = smallblue
    
    //------------------ Настройка дизайна
    tableView.backgroundColor = UIColor(red: red/255, green: (green+80)/255, blue: blue/255, alpha: 1)
    imageShoppingScrene.backgroundColor = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1) // Цвет фона над таблицей
    bottomView.backgroundColor = tableView.backgroundColor // Цвет View под таблицей
    
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
      if let countList = self.listShopping {
        
        return countList.count
      }
      
      return 0

    }

  //-----------------------------------// Метод для работы и настройки Cell в TableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      //------------------ Создаем ячейку по идентификатору с indexPath в методе для работы и настройки Cell в TableView
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingCell", forIndexPath: indexPath) as! ShoppingTableViewCell
      
        cell.nameShoppingLabel.text = sortingListShopping[indexPath.row].name // Перебор имен продуктов для создание списка
      
        cell.backgroundColor = tableView.backgroundColor
      
        return cell
    }
  
  //-----------------------------------// Метод для работы cо свайпом ячейки. Стандартные кнопки (без нее свайпа нет)
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
    
  }
  
  //-----------------------------------// Метод для работы с действиями по свайпу ячейки
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    
    //------------------ Действие: продукт в корзине покупок. Кнопка на весь экран
    let delete = UITableViewRowAction(style: .Default, title: "   В Корзину         ") {(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
      
      let product = self.sortingListShopping[indexPath.row] // Объект в выбранной ячейке для его удаления
      
       let countShoppingList = realm.objects(ShoppingListRealm).count // Количество объектов в списке перед удалением
      
      //------------------Вынимаем объект из памяти listProduct с таким же именем, что и имя в выбранной ячейке
      let updateProduct = realm.objects(GroceriesLibraryRealm).filter("name = %@", product.name)
      
      //------------------Обновление информации о продукте в listProduct
      try! realm.write {
        
        updateProduct.first?.raiting = (updateProduct.first?.raiting)! - (Double(countShoppingList)/Double((updateProduct.first?.countQueries)!)) // Меняем рейтинг по закону рейтинг = рейтинг + (кол-во товаров в списке покупок/общее кол-во вызовов данного продукта из библиотеки)
        
        updateProduct.first?.countQueries += 1 // Меняем количество попаданий в listShopping
        
      }
      
      //------------------ Удаление через Realm из listShopping
      try! realm.write { realm.delete(product) }
      
      self.updateListLibrary() // Метод для перезаписи списка и перезагрузки таблицы
      
      self.massInListShopping(&self.red, blue: &self.blue) // Подсчет массы покупок
      
    }
    
    delete.backgroundColor = UIColor(red: red/255, green: (green+200)/255, blue: blue/255, alpha: 1)
    
    //------------------ Действие: продукт в корзине покупок. Кнопка на весь экран
    let bufer = UITableViewRowAction(style: .Default, title: "   Удалить         ") {(action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
      
      let product = self.sortingListShopping[indexPath.row] // Объект в выбранной ячейке для его удаления
      
      //------------------ Удаление через Realm из listShopping
      try! realm.write { realm.delete(product) }
      
      self.updateListLibrary() // Метод для перезаписи списка и перезагрузки таблицы
      
      self.massInListShopping(&self.red, blue: &self.blue) // Подсчет массы покупок
      
    }
    
    bufer.backgroundColor = UIColor(red: red/255, green: (green+150)/255, blue: blue/255, alpha: 1)
    
    return [delete, bufer]
    
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
