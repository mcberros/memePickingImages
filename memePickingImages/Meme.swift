//
//  Meme.swift
//  memePickingImages
//
//  Created by Carmen Berros on 29/11/15.
//  Copyright © 2015 mcberros. All rights reserved.
//

import Foundation
import UIKit

class Meme {
    private var topText: String!
    private var bottonText: String!
    private var originalImage: UIImage!
    var memedImage: UIImage!

    init(topText: String, bottonText: String, originalImage: UIImage, memedImage: UIImage){
        self.topText = topText
        self.bottonText = bottonText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
