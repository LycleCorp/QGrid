//
//  QGrid.swift
//  QGrid
//
//  Created by Karol Kulesza on 7/06/19.
//  Copyright © 2019 Q Mobile { http://Q-Mobile.IT }
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI


/// A container that presents rows of data arranged in multiple columns.
@available(iOS 13.0, OSX 10.15, *)
public struct QGrid<Data, Content>: View
  where Data : RandomAccessCollection, Content : View, Data.Element : Identifiable {
  private struct QGridIndex : Identifiable { var id: Int }
  
  // MARK: - STORED PROPERTIES
  
  private let columns: Int
  private let columnsInLandscape: Int
  private let availableContainerWidth: CGFloat
  private let vSpacing: CGFloat
  private let hSpacing: CGFloat
  private let vPadding: CGFloat
  private let hPadding: CGFloat
  private let isScrollable: Bool
  private let showScrollIndicators: Bool
  private let data: [Data.Element]
  private let smallHeightAutoExpandsToMatchLongestItem: Bool
  private let content: (Data.Element) -> Content
  
  // MARK: - INITIALIZERS
  
  /// Creates a QGrid that computes its cells from an underlying collection of identified data.
  ///
  /// - Parameters:
  ///     - data: A collection of identified data.
  ///     - columns: Target number of columns for this grid, in Portrait device orientation
  ///     - columnsInLandscape: Target number of columns for this grid, in Landscape device orientation; If not provided, `columns` value will be used.
    ///   - availableContainerWidth: The width in which cells should be resized, Make sure you include your left and right paddings. Default is UIScreen.main.bounds.width - 32.
  ///     - vSpacing: Vertical spacing: The distance between each row in grid. If not provided, the default value will be used.
  ///     - hSpacing: Horizontal spacing: The distance between each cell in grid's row. If not provided, the default value will be used.
  ///     - vPadding: Vertical padding: The distance between top/bottom edge of the grid and the parent view. If not provided, the default value will be used.
  ///     - hPadding: Horizontal padding: The distance between leading/trailing edge of the grid and the parent view. If not provided, the default value will be used.
  ///     - isScrollable: Boolean that determines whether or not the grid should scroll
    ///   - smallHeightAutoExpandsToMatchLongestItem: Boolean determines wether cells in the same row should be auto resized to match longest one.
  ///     - content: A closure returning the content of the individual cell
  public init(_ data: Data,
              columns: Int,
              columnsInLandscape: Int? = nil,
              availableContainerWidth: CGFloat = UIScreen.main.bounds.width - 32,
              vSpacing: CGFloat = 10,
              hSpacing: CGFloat = 10,
              vPadding: CGFloat = 10,
              hPadding: CGFloat = 10,
              isScrollable: Bool = true,
              showScrollIndicators: Bool = false,
              smallHeightAutoExpandsToMatchLongestItem: Bool = false,
              content: @escaping (Data.Element) -> Content) {
    self.data = data.map { $0 }
    self.content = content
    self.columns = max(1, columns)
    self.columnsInLandscape = columnsInLandscape ?? max(1, columns)
    self.availableContainerWidth = availableContainerWidth
    self.vSpacing = vSpacing
    self.hSpacing = hSpacing
    self.vPadding = vPadding
    self.hPadding = hPadding
    self.isScrollable = isScrollable
      self.smallHeightAutoExpandsToMatchLongestItem = smallHeightAutoExpandsToMatchLongestItem
    self.showScrollIndicators = showScrollIndicators
  }
  
  // MARK: - COMPUTED PROPERTIES
  
  private var rows: Int {
    data.count / self.cols
  }
  
  private var cols: Int {
    #if os(tvOS)
    return columnsInLandscape
    #elseif os(macOS)
    return columnsInLandscape
    #else
    return UIDevice.current.orientation.isLandscape ? columnsInLandscape : columns
    #endif
  }
  
  /// Declares the content and behavior of this view.
  public var body : some View {
      let availableContainerWidth: CGFloat = UIScreen.main.bounds.width - 32
      Group {
        if !self.data.isEmpty {
            if self.isScrollable {
              ScrollView(showsIndicators: self.showScrollIndicators) {
                  self.content(using: availableContainerWidth)
              }
            } else {
                self.content(using: availableContainerWidth)
            }
          }
      }
      .padding(.horizontal, self.hPadding)
      .padding(.vertical, self.vPadding)
  }
  
  // MARK: - `BODY BUILDER` 💪 FUNCTIONS
  
  private func rowAtIndex(_ index: Int,
                          availableWidth: CGFloat,
                          isLastRow: Bool = false) -> some View {
    HStack(spacing: self.hSpacing) {
      ForEach((0..<(isLastRow ? data.count % cols : cols))
      .map { QGridIndex(id: $0) }) { column in
        self.content(self.data[index + column.id])
        .frame(width: self.contentWidthFor(availableWidth))
        .frame(maxHeight: .infinity)
      }
      if isLastRow { Spacer() }
    }
    .fixedSize(horizontal: false, vertical: smallHeightAutoExpandsToMatchLongestItem ?  true : false)
  }
    
  private func content(using availableWidth:CGFloat) -> some View {
   VStack(spacing: self.vSpacing) {
     ForEach((0..<self.rows).map { QGridIndex(id: $0) }) { row in
       self.rowAtIndex(row.id * self.cols,
                       availableWidth: availableWidth)
     }
     // Handle last row
     if (self.data.count % self.cols > 0) {
       self.rowAtIndex(self.cols * self.rows,
                       availableWidth: availableWidth,
                       isLastRow: true)
     }
   }
 }
    
  // MARK: - HELPER FUNCTIONS
  
  private func contentWidthFor(_ availableWidth: CGFloat) -> CGFloat {
    let hSpacings = hSpacing * (CGFloat(self.cols) - 1)
    let width = availableWidth - hSpacings - hPadding * 2
    return width / CGFloat(self.cols)
  }
}

