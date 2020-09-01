//
//  ScannerCoverView.swift
//  CodeScanner
//
//  Created by yunhui wu on 2020/9/1.
//  Copyright © 2020 yunhui wu. All rights reserved.
//

import UIKit

class CodeScannerView: UIView {
    // MARK: - public
    
    /// 扫描区域所占比例 0 ~ 1
    var scanAreaScale: CGFloat = 0.8
    /// 扫描边框宽度
    var scanAreaBorderWidth: CGFloat = 1
    /// 扫描边框的颜色
    var scanAreaBorderColor: UIColor = .darkGray
    /// 扫描线颜色
    var scanLineColor: UIColor = .yellow
    /// 扫描线宽度
    var scanLineWidth: CGFloat = 2
    /// 扫描线透明度
    var scanLineOpacity: CGFloat = 0.3
    
    // MARK: - private
    
    /// 扫描区域宽度
    private var scanAreaWidth: CGFloat {
        bgView.bounds.width * scanAreaScale
    }
    
    /// 扫描线宽度
    private var scanLineLength: CGFloat {
        scanAreaWidth - 2 * scanAreaBorderWidth
    }
    
    /// 背景
    private lazy var bgView: UIView = {
        let tmp = UIView()
        tmp.frame = self.bounds
        return tmp
    }()
    
    /// 扫描区域
    private lazy var scanView: UIView = {
        let tmp = UIView()
        tmp.center = self.bgView.center
        tmp.bounds.size = CGSize(width: scanAreaWidth, height: scanAreaWidth)
        tmp.layer.borderColor = scanAreaBorderColor.cgColor
        tmp.layer.borderWidth = scanAreaBorderWidth
        return tmp
    }()
    
    /// 扫描线
    private lazy var scanLine: UIView = {
        let tmp = UIView()
        tmp.backgroundColor = scanLineColor
        tmp.alpha = scanLineOpacity
        tmp.frame.origin = CGPoint(x: self.scanAreaBorderWidth, y: self.scanAreaBorderWidth)
        tmp.frame.size = CGSize(width: scanLineLength, height: scanLineWidth)
        return tmp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
        makeTransparent()
        startScanAnimation()
    }
    
    /// 构建 UI
    private func setupUI() {
        addSubview(bgView)
        bgView.addSubview(scanView)
        scanView.addSubview(scanLine)
    }
    
    /// 更新约束
    private func updateLayout() {
        bgView.frame = bounds
        scanView.center = bgView.center
        scanView.bounds.size = CGSize(width: scanAreaWidth, height: scanAreaWidth)
        scanLine.frame.origin = CGPoint(x: scanAreaBorderWidth, y: scanAreaBorderWidth)
        scanLine.frame.size = CGSize(width: scanLineLength, height: 2)
    }
    
    /// 中间镂空
    private func makeTransparent() {
        let overlayPath = UIBezierPath(rect: bgView.bounds)
        let transparentRectPath = UIBezierPath(rect: scanView.frame)
        overlayPath.append(transparentRectPath)
        overlayPath.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.5
        
        bgView.layer.addSublayer(fillLayer)
    }
    
    /// 开始扫描动画
    private func startScanAnimation() {
        layer.removeAllAnimations()
        UIView.animateKeyframes(withDuration: 2, delay: 0, options: [.repeat], animations: { [weak self] in
            guard let weakSelf = self else { return }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                weakSelf.scanLine.center.y = weakSelf.scanView.bounds.maxY - 5
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 1) {
                weakSelf.scanLine.center.y = weakSelf.scanAreaBorderWidth
            }
        })
    }
}
