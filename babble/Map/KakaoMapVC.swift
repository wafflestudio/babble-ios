//
//  CurrentPositionPOISample.swift
//  KakaoMapOpenApi-Sample
//
//  Created by chase on 2020/06/05.
//  Copyright © 2020 kakao. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import KakaoMapsSDK
import SwiftUI

enum Mode: Int {
    case hidden = 0,
    show,
    tracking
}

class KakaoMapVC: KakaoMapAPIBaseVC, GuiEventDelegate, KakaoMapEventDelegate, CLLocationManagerDelegate {
    var viewmodel: ChatRoomsViewModel?
    
    override init() {
        _locationServiceAuthorized = CLAuthorizationStatus.notDetermined
        _locationManager = CLLocationManager()
        _locationManager.distanceFilter = kCLDistanceFilterNone
        _locationManager.headingFilter = kCLHeadingFilterNone
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _currentHeading = 0
        _currentPosition = GeoCoordinate()
        _mode = .show
        _moveOnce = true

        super.init()

        _locationManager.delegate = self
        onAuthorizationGiven = { [weak self] in
            guard let self = self else { return }
            // Execute any tasks that depend on having location access here
            self.setupLocationDependentFeatures()
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        _locationServiceAuthorized = CLAuthorizationStatus.notDetermined
        _locationManager = CLLocationManager()
        _locationManager.distanceFilter = kCLDistanceFilterNone
        _locationManager.headingFilter = kCLHeadingFilterNone
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _currentHeading = 0
        _currentPosition = GeoCoordinate()
        _mode = .show
        _moveOnce = true
        super.init(coder: aDecoder)
        
        _locationManager.delegate = self
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapContainer = KMViewContainer(frame: self.view.bounds)
        self.view.addSubview(mapContainer!)
        
        //KMController 생성.
        mapController = KMController(viewContainer: mapContainer!)
        mapController!.delegate = self
        
        _timer = Timer.init(timeInterval: 0.3, target: self, selector: #selector(self.updateCurrentPositionPOI), userInfo: nil, repeats: true)
        RunLoop.current.add(_timer!, forMode: RunLoop.Mode.common)
        startUpdateLocation()
        mapController?.initEngine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _appear = false
        mapController?.stopRendering()  //렌더링 중지.
        _timer?.invalidate()
    }

    
    func setupLocationDependentFeatures() {
        _currentPositionPoi?.show()
        _currentDirectionArrowPoi?.show()
        _moveOnce = true
        createPolygonShape()
        viewmodel?.fetchChatRooms(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude) {
            self.createSharedLocationPois()
        }
    }
    
    override func addViews() {
        let position: MapPoint = MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude)
        //let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: position)
        
        if mapController?.addView(mapviewInfo) == Result.OK {
            print("OK")
            createShapeLayer()
            createPolygonStyleSet()
            createSpriteGUI()
            createLabelLayer()
            createPoiStyle()
            createPois()
            createLayer()
            createSharedLocationStyle()
        }
    }
    
    
    // PolygonShape를 추가하기 위해 ShapeLayer를 생성한다.
    func createShapeLayer() {
        let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getShapeManager()
        let _ = manager.addShapeLayer(layerID: "polygons", zOrder: 10001)
    }
    
    // PolygonShape에서 사용할 스타일셋을 만든다.
    func createPolygonStyleSet() {
        let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getShapeManager()
        
        let fillColor = UIColor(hex: 0x80A6F288) // Example fill color
        let strokeColor = UIColor(hex: 0x0C2FF2FF) // Example stroke color

        let styleSet = PolygonStyleSet(styleSetID: "polygonStyleSet")
        let perLevelStyle = PerLevelPolygonStyle(color: fillColor, strokeWidth: 3, strokeColor: strokeColor, level: 0)
        let style = PolygonStyle(styles: [perLevelStyle])
            
        styleSet.addStyle(style)

        manager.addPolygonStyleSet(styleSet)
    }
    
    // 하나의 원으로 구성된 PolygonShape를 만든다.
    func createPolygonShape() {
        let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getShapeManager()
        let layer = manager.getShapeLayer(layerID: "polygons")
        let center = MapPoint(longitude: 127.038575, latitude: 37.499699)
        //let center = MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude)
        
        _polygons = [MapPolygon]()
        _polygons?.append(MapPolygon(exteriorRing: Primitives.getCirclePoints(radius: 500, numPoints: 90, cw: true, center: center), hole: nil, styleIndex: 0))
        
        let option = MapPolygonShapeOptions(shapeID: "polygonShape", styleID: "polygonStyleSet", zOrder: 0)
        option.polygons = _polygons!
        
        let shape = layer?.addMapPolygonShape(option) { (polygon: MapPolygonShape?) -> Void in
            polygon?.show()
            //mapView.moveCamera(CameraUpdate.make(target: center, zoomLevel: 15, mapView: mapView))
        }
        
        _currentDirectionPoi?.shareTransformWithShape(shape!)
    }

    
    func createLabelLayer() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let positionLayerOption = LabelLayerOptions(layerID: "PositionPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 1500)
        let _ = manager.addLabelLayer(option: positionLayerOption)
        let directionLayerOption = LabelLayerOptions(layerID: "DirectionPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 1000)
        let _ = manager.addLabelLayer(option: directionLayerOption)
    }
    
    func createPoiStyle() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        //let marker = PoiIconStyle(symbol: UIImage(named: "map_ico_marker.png"))
        let marker = PoiIconStyle(symbol: UIImage(systemName: "figure.wave"))
        let perLevelStyle1 = PerLevelPoiStyle(iconStyle: marker, level: 0)
        let poiStyle1 = PoiStyle(styleID: "positionPoiStyle", styles: [perLevelStyle1])
        manager.addPoiStyle(poiStyle1)
        
        //let direction = PoiIconStyle(symbol: UIImage(named: "map_ico_marker_direction.png"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
        let direction = PoiIconStyle(symbol: UIImage(named: "direction"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
        let perLevelStyle2 = PerLevelPoiStyle(iconStyle: direction, level: 0)
        let poiStyle2 = PoiStyle(styleID: "directionArrowPoiStyle", styles: [perLevelStyle2])
        manager.addPoiStyle(poiStyle2)
        
        //let area = PoiIconStyle(symbol: UIImage(named: "map_ico_direction_area.png"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
        let area = PoiIconStyle(symbol: UIImage(systemName: "atriangle.fill"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
        let perLevelStyle3 = PerLevelPoiStyle(iconStyle: area, level: 0)
        let poiStyle3 = PoiStyle(styleID: "directionPoiStyle", styles: [perLevelStyle3])
        manager.addPoiStyle(poiStyle3)
    }
    
    func createPois() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let positionLayer = manager.getLabelLayer(layerID: "PositionPoiLayer")
        let directionLayer = manager.getLabelLayer(layerID: "DirectionPoiLayer")
        
        // 현위치마커의 몸통에 해당하는 POI
        let poiOption = PoiOptions(styleID: "positionPoiStyle", poiID: "PositionPOI")
        poiOption.rank = 3
        poiOption.transformType = .decal    //화면이 기울여졌을 때, 지도를 따라 기울어져서 그려지도록 한다.
        //let position: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let position: MapPoint = MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude)
        
        _currentPositionPoi = positionLayer?.addPoi(option:poiOption, at: position)
        
        // 현위치마커의 방향표시 화살표에 해당하는 POI
        let poiOption2 = PoiOptions(styleID: "directionArrowPoiStyle", poiID: "DirectionArrowPOI")
        poiOption2.rank = 1
        poiOption2.transformType = .absoluteRotationDecal
        
        _currentDirectionArrowPoi = positionLayer?.addPoi(option:poiOption2, at: position)
        
        // 현위치마커의 부채꼴모양 방향표시에 해당하는 POI
        let poiOption3 = PoiOptions(styleID: "directionPoiStyle", poiID: "DirectionPOI")
        poiOption3.rank = 2
        poiOption3.transformType = .decal
        
        _currentDirectionPoi = directionLayer?.addPoi(option:poiOption3, at: position)
        
        _currentPositionPoi?.shareTransformWithPoi(_currentDirectionArrowPoi!)  //몸통이 방향표시와 위치 및 방향을 공유하도록 지정한다. 몸통 POI의 위치가 변경되면 방향표시 POI의 위치도 변경된다. 반대는 변경안됨.
        _currentDirectionArrowPoi?.shareTransformWithPoi(_currentDirectionPoi!) //방향표시가 부채꼴모양과 위치 및 방향을 공유하도록 지정한다.
    }
    
    func createLayer() {
        let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getLabelManager()
        // zOrder값을 조절해서 CurrentPositionMarker를 구성하는 location poi, direction area, direction poi와의 렌더링 순서를 조절한다.
        let option = LabelLayerOptions(layerID: "chatroomPOILayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 1501)
        let _ = manager.addLabelLayer(option: option)
    }
    
    func createSharedLocationStyle() {
        let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getLabelManager()
                
        let marker = PoiIconStyle(symbol: UIImage(systemName: "message.fill"))
        let perLevelStyle1 = PerLevelPoiStyle(iconStyle: marker, level: 0)
        let poiStyle1 = PoiStyle(styleID: "chatroomStyle", styles: [perLevelStyle1])
        manager.addPoiStyle(poiStyle1)
    }

    
    func createSharedLocationPois() {
        let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "chatroomPOILayer")

        /*var points = [
            MapPoint(longitude: 127.040707, latitude: 37.500383),
            MapPoint(longitude: 127.035393, latitude: 37.501440),
            MapPoint(longitude: 127.035082, latitude: 37.505012),
            MapPoint(longitude: 127.040038, latitude: 37.503435),
            MapPoint(longitude: 127.036693, latitude: 37.501240),
            MapPoint(longitude: 127.042944, latitude: 37.505231),
            MapPoint(longitude: 127.041496, latitude: 37.499066),
            MapPoint(longitude: 127.039881, latitude: 37.502589),
            MapPoint(longitude: 127.040264, latitude: 37.500471),
            MapPoint(longitude: 127.037507, latitude: 37.499449)
        ]*/
        
        if let rooms = viewmodel?.rooms {
            for room in rooms {
                let point = MapPoint(longitude: room.longitude, latitude: room.latitude)
                let poiOptions = PoiOptions(styleID: "chatroomStyle", poiID: "\(room.id)")
                poiOptions.clickable = true
                if let poi = layer?.addPoi(option: poiOptions, at: point) {
                    let _ = poi.addPoiTappedEventHandler(target: self, handler: KakaoMapVC.clickedChatroom)
                    poi.show()
                }
            }
        }
    }
    
    func clickedChatroom(_ param: PoiInteractionEventParam) {
        @State var isLoggedIn = false
        let roomId = param.poiItem.itemID
        let room = viewmodel!.rooms.first{
            room in room.id == Int(roomId)
        }
        let swiftUIView = ChatRoomView(viewModel: ChatViewModel(chatRoom: room!))
        let hostingController = UIHostingController(rootView: swiftUIView)
        self.navigationController?.pushViewController(hostingController, animated: true)

        print(param.poiItem.itemID)
        
    }


    
    // 현위치마커 버튼 GUI
    func createSpriteGUI() {
        let mapView = mapController?.getView("mapview") as! KakaoMap
        let spriteLayer = mapView.getGuiManager().spriteGuiLayer
        let spriteGui = SpriteGui("ButtonGui")
        
        spriteGui.arrangement = .horizontal
        spriteGui.bgColor = UIColor.clear
        spriteGui.splitLineColor = UIColor.white
        spriteGui.origin = GuiAlignment(vAlign: .bottom, hAlign: .right)
        spriteGui.position = CGPoint(x: 30, y: 60)

        
        let button = GuiButton("CPB")
        //button.image = UIImage(named: "track_location_btn.png")
        button.image = UIImage(systemName: "location.circle")

        spriteGui.addChild(button)
        
        spriteLayer.addSpriteGui(spriteGui)
        spriteGui.delegate = self
        spriteGui.show()
    }
    
    func guiDidTapped(_ gui: KakaoMapsSDK.GuiBase, componentName: String) {
//        let mapView = mapController?.getView("mapview") as! KakaoMap
        let button = gui.getChild(componentName) as! GuiButton
        switch _mode {
            case .hidden:
                _mode = .show   //현위치마커 표시
                //button.image = UIImage(named: "track_location_btn_pressed.png")
                button.image = UIImage(systemName: "location.circle")
                _timer = Timer.init(timeInterval: 0.3, target: self, selector: #selector(self.updateCurrentPositionPOI), userInfo: nil, repeats: true)
                RunLoop.current.add(_timer!, forMode: RunLoop.Mode.common)
                startUpdateLocation()
                _currentPositionPoi?.show()
                _currentDirectionArrowPoi?.show()
                _moveOnce = true
                break;
            case .show:
                _mode = .tracking   //현위치마커 추적모드
                //button.image = UIImage(named: "track_location_btn_compass_on.png")
                button.image = UIImage(systemName: "location.circle")
                let mapView = mapController?.getView("mapview") as! KakaoMap
                let trackingManager = mapView.getTrackingManager()
                trackingManager.startTrackingPoi(_currentDirectionArrowPoi!)
                trackingManager.isTrackingRoll = true
                _currentDirectionArrowPoi?.hide()
                _currentDirectionPoi?.show()
                break;
            case .tracking:
                _mode = .show     //현위치마커 숨김
                //button.image = UIImage(named: "track_location_btn.png")
                button.image = UIImage(systemName: "location.circle")
                let mapView = mapController?.getView("mapview") as! KakaoMap
                let trackingManager = mapView.getTrackingManager()
                trackingManager.stopTracking()
                _currentDirectionArrowPoi?.show()
                _currentDirectionPoi?.hide()
        }
        gui.updateGui()
    }
    
    @objc func updateCurrentPositionPOI() {
        _currentPositionPoi?.moveAt(MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude), duration: 150)
        _currentDirectionArrowPoi?.rotateAt(_currentHeading, duration: 150)
                
        if _moveOnce {
            let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
            mapView.moveCamera(CameraUpdate.make(target: MapPoint(longitude: _currentPosition.longitude, latitude: _currentPosition.latitude), mapView: mapView))
            _moveOnce = false
        }
//        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
//        let manager = mapView?.getShapeManager()
//        let layer = manager?.getShapeLayer("shapeLayer")
//        let shape = layer?.getShape("waveShape")
    }

    func startUpdateLocation() {
        if _locationServiceAuthorized != .authorizedWhenInUse {
            _locationManager.requestWhenInUseAuthorization()
        }
        else {
            _locationManager.startUpdatingLocation()
            _locationManager.startUpdatingHeading()
        }
    }

    func stopUpdateLocation() {
        _locationManager.stopUpdatingHeading()
        _locationManager.stopUpdatingLocation()
    }

    /*func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        _locationServiceAuthorized = status
        if _locationServiceAuthorized == .authorizedWhenInUse && (_mode == .show || _mode == .tracking) {
            _locationManager.startUpdatingLocation()
            _locationManager.startUpdatingHeading()
        }
    }*/
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        _locationServiceAuthorized = status
        switch status {
        case .authorizedWhenInUse:
            onAuthorizationGiven?()
            _locationManager.startUpdatingLocation()
            _locationManager.startUpdatingHeading()
        default:
            break
        }
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _currentPosition.longitude = locations[0].coordinate.longitude
        _currentPosition.latitude = locations[0].coordinate.latitude
        
//        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
//        let manager = mapView?.getMapMovablePoiManager()
//        let poi = manager?.getMovablePoi("me")
//        poi?.updatePosition(_currentPosition)
//        manager?.animateMovablePois(pois: [poi!], duration: 1000)
        
    //        NSLog("CurrentLocation: %f, %f", locations[0].coordinate.longitude, locations[0].coordinate.latitude)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        _currentHeading = newHeading.trueHeading * Double.pi / 180.0
    }
    
    var _timer: Timer?
    var _currentPositionPoi: Poi?
    var _currentDirectionArrowPoi: Poi?
    var _currentDirectionPoi: Poi?
    var _currentHeading: Double
    var _currentPosition: GeoCoordinate
    var _mode: Mode
    var _moveOnce: Bool
    var _locationManager: CLLocationManager
    var _locationServiceAuthorized: CLAuthorizationStatus
    var onAuthorizationGiven: (() -> Void)?
    var _polygons: [MapPolygon]?
    var _shapeLayer: ShapeLayer?
    var _shape: MapPolygonShape?
}

extension UIColor {
    public convenience init(hex: UInt32) {
        let r, g, b, a: CGFloat
        r = CGFloat((hex & 0xff000000) >> 24) / 255.0
        g = CGFloat((hex & 0x00ff0000) >> 16) / 255.0
        b = CGFloat((hex & 0x0000ff00) >> 8) / 255.0
        a = CGFloat((hex & 0x000000ff)) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
