/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct SurfaceView: View {
  @ObservedObject var mesh: Mesh
  @ObservedObject var selection: SelectionHandler
  
  //dragging
  @State var portalPosition: CGPoint = .zero
  @State var dragOffset: CGSize = .zero
  @State var isDragging: Bool = false
  @State var isDraggingMesh: Bool = false
  
  //zooming
  @State var zoomScale: CGFloat = 1.0
  @State var initialZoomScale: CGFloat?
  @State var initialPortalPosition: CGPoint?
  
  var body: some View {
    VStack {
      // 1
      Text("drag offset = w:\(dragOffset.width), h:\(dragOffset.height)")
      Text("portal offset = x:\(portalPosition.x), y:\(portalPosition.y)")
      Text("zoom = \(zoomScale)")
      TextField("Breathe…", text: $selection.editingText, onCommit: {
        if let node = self.selection.onlySelectedNode(in: self.mesh) {
          self.mesh.updateNodeText(node, string: self.self.selection.editingText)
        }
      })
      // 2
      GeometryReader { geometry in
        // 3
        ZStack {
          Rectangle().fill(Color.yellow)
          MapView(selection: self.selection, mesh: self.mesh)
            .scaleEffect(self.zoomScale)
            // 4
            .offset(
              x: self.portalPosition.x + self.dragOffset.width,
              y: self.portalPosition.y + self.dragOffset.height)
            .animation(.easeIn)
        }
        .gesture(DragGesture()
        .onChanged { value in
          self.processDragChange(value, containerSize: geometry.size)
        }
        .onEnded { value in
          self.processDragEnd(value)
        })
          .gesture(MagnificationGesture()
            .onChanged { value in
              // 1
              if self.initialZoomScale == nil {
                self.initialZoomScale = self.zoomScale
                self.initialPortalPosition = self.portalPosition
              }
              self.processScaleChange(value)
          }
          .onEnded { value in
            // 2
            self.processScaleChange(value)
            self.initialZoomScale = nil
            self.initialPortalPosition  = nil
          })
      }
    }
  }
}

struct SurfaceView_Previews: PreviewProvider {
  static var previews: some View {
    let mesh = Mesh.sampleProceduralMesh()
    let selection = SelectionHandler()
    return SurfaceView(mesh: mesh, selection: selection)
  }
}

private extension SurfaceView {
  // 1
  func distance(from pointA: CGPoint, to pointB: CGPoint) -> CGFloat {
    let xdelta = pow(pointA.x - pointB.x, 2)
    let ydelta = pow(pointA.y - pointB.y, 2)
    
    return sqrt(xdelta + ydelta)
  }
  
  // 2
  func hitTest(point: CGPoint, parent: CGSize) -> Node? {
    for node in mesh.nodes {
      let endPoint = node.position
        .scaledFrom(zoomScale)
        .alignCenterInParent(parent)
        .translatedBy(x: portalPosition.x, y: portalPosition.y)
      let dist =  distance(from: point, to: endPoint) / zoomScale
      
      //3
      if dist < NodeView.width / 2.0 {
        return node
      }
    }
    return nil
  }
  
  // 4
  func processNodeTranslation(_ translation: CGSize) {
    guard !selection.draggingNodes.isEmpty else { return }
    let scaledTranslation = translation.scaledDownTo(zoomScale)
    mesh.processNodeTranslation(
      scaledTranslation,
      nodes: selection.draggingNodes)
  }
  
  func processDragChange(_ value: DragGesture.Value, containerSize: CGSize) {
    // 1
    if !isDragging {
      isDragging = true
      
      if let node = hitTest(
        point: value.startLocation,
        parent: containerSize) {
        isDraggingMesh = false
        selection.selectNode(node)
        // 2
        selection.startDragging(mesh)
      } else {
        isDraggingMesh = true
      }
    }
    
    // 3
    if isDraggingMesh {
      dragOffset = value.translation
    } else {
      processNodeTranslation(value.translation)
    }
  }
  
  // 4
  func processDragEnd(_ value: DragGesture.Value) {
    isDragging = false
    dragOffset = .zero
    
    if isDraggingMesh {
      portalPosition = CGPoint(
        x: portalPosition.x + value.translation.width,
        y: portalPosition.y + value.translation.height)
    } else {
      processNodeTranslation(value.translation)
      selection.stopDragging(mesh)
    }
  }
  
  // 1
  func scaledOffset(_ scale: CGFloat, initialValue: CGPoint) -> CGPoint {
    let newx = initialValue.x*scale
    let newy = initialValue.y*scale
    return CGPoint(x: newx, y: newy)
  }
  
  func clampedScale(_ scale: CGFloat, initialValue: CGFloat?) -> (scale: CGFloat, didClamp: Bool) {
    let minScale: CGFloat = 0.1
    let maxScale: CGFloat = 2.0
    let raw = scale.magnitude * (initialValue ?? maxScale)
    let value =  max(minScale, min(maxScale, raw))
    let didClamp = raw != value
    return (value, didClamp)
  }
  
  func processScaleChange(_ value: CGFloat) {
    let clamped = clampedScale(value, initialValue: initialZoomScale)
    zoomScale = clamped.scale
    if !clamped.didClamp,
      let point = initialPortalPosition {
      portalPosition = scaledOffset(value, initialValue: point)
    }
  }
}
