//
//  Data+Ext.swift
//  Planus
//
//  Created by Sangmin Lee on 2023/08/08.
//

import Foundation

extension Data {
    var isImageData: Bool {
        let array = self.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: 10))
        }
        let intervals: [[UInt8]] = [
            [0x42, 0x4D], // bmp
            [0xFF, 0xD8, 0xFF], // jpg
            [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A], // png
            [0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20], // jpeg2000
            [0x49, 0x49, 0x2A, 0x00], // tiff1
            [0x4D, 0x4D, 0x00, 0x2A] // tiff2
        ]

        for interval in intervals {
            var image = true
            for i in 0..<interval.count {
                if array[i] != interval[i] {
                    image = false
                    break
                }
            }
            if image { return true }
        }
        return false
    }
}
