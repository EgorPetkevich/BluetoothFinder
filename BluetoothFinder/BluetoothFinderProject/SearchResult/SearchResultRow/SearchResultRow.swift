//
//  SearchResultRow.swift
//  blekokofinder
//
//  Created by Developer on 13.06.25.
//

import SwiftUI

struct SearchResultRow: View {

    let icon: ImageResource
    let title: String
    let time: String
    let meters: String

    var body: some View {
        HStack {
            Image(icon)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                Text(time)
                    .foregroundStyle(.white).opacity(0.5)
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Text(meters)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal)
                .padding(.vertical, 2)
                .background(.mainBlue)
                .foregroundStyle(.white)
                .cornerRadius(12)
        }
        .padding()
        .background(.row)
        .cornerRadius(8)
    }
}
