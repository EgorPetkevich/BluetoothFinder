//
//  FavorietSearchRow.swift
//  blekokofinder
//
//  Created by George Popkich on 1.07.25.
//

import SwiftUI

struct FavorietSearchRow: View {
    let icon: ImageResource
    let title: String
    let time: String
    let meters: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)

                Text(time)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .opacity(0.5)
            }

            Spacer()

            Text(meters)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal)
                .padding(.vertical, 2)
                .background(.mainBlue)
                .foregroundStyle(.white)
                .cornerRadius(12)

            ZStack {
                Circle()
                    .strokeBorder(isSelected ? Color.blue : Color.white, lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.clear)
                    )
                    .frame(width: 24, height: 24)

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                        
                }
            }
        }
        .padding()
        .background(.row)
        .cornerRadius(8)
    }
}
