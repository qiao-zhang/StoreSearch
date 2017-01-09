//
// Created by Qiao Zhang on 1/2/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import UIKit

struct SearchResultCellItem {
  let name: String
  let category: String
  let artistName: String
}

func < (lhs: SearchResultCellItem, rhs: SearchResultCellItem) -> Bool {
  return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}
