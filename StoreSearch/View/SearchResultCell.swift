//
// Created by Qiao Zhang on 1/2/17.
// Copyright (c) 2017 Qiao Zhang. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var categoryLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    let selectedView = UIView(frame: CGRect.zero)
    selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255,
                                           blue: 160/255, alpha: 0.5)
    selectedBackgroundView = selectedView
  }

  func config(with item: SearchResultCellItem) {
    nameLabel.text = item.name
    categoryLabel.text = item.category
    artistNameLabel.text = item.artistName
  }
}
