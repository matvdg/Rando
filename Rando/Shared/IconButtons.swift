import SwiftUI


let ICON_BUTTON_SIZE: CGFloat = 35
let ICON_BUTTON_SYMBOL_SIZE: CGFloat = 18
let ICON_BUTTON_OPACITY: CGFloat = 0.7

struct BackIconButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(ICON_BUTTON_OPACITY))
                .frame(width: ICON_BUTTON_SIZE, height: ICON_BUTTON_SIZE)
            Image(systemName: "chevron.left")
                .font(.system(size: ICON_BUTTON_SYMBOL_SIZE, weight: .bold))
                .foregroundColor(.white)
                .frame(width: ICON_BUTTON_SYMBOL_SIZE, height: ICON_BUTTON_SYMBOL_SIZE)
        }
    }
}

struct LikeIconButton: View {
    
    @Binding var isLiked: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(ICON_BUTTON_OPACITY))
                .frame(width: ICON_BUTTON_SIZE, height: ICON_BUTTON_SIZE)
            Image(systemName: isLiked ? "heart.fill" : "heart")
                .font(.system(size: ICON_BUTTON_SYMBOL_SIZE, weight: .bold))
                .foregroundColor(.white)
                .frame(width: ICON_BUTTON_SYMBOL_SIZE, height: ICON_BUTTON_SYMBOL_SIZE)
        }
    }
}


struct EditIconButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(ICON_BUTTON_OPACITY))
                .frame(width: ICON_BUTTON_SIZE, height: ICON_BUTTON_SIZE)
            Image(systemName: "pencil")
                .font(.system(size: ICON_BUTTON_SYMBOL_SIZE, weight: .black))
                .foregroundColor(.white)
                .frame(width: ICON_BUTTON_SYMBOL_SIZE, height: ICON_BUTTON_SYMBOL_SIZE)
        }
    }
}

struct ShareIconButton: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(ICON_BUTTON_OPACITY))
                .frame(width: ICON_BUTTON_SIZE, height: ICON_BUTTON_SIZE)
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: ICON_BUTTON_SYMBOL_SIZE, weight: .bold))
                .foregroundColor(.white)
                .frame(width: ICON_BUTTON_SYMBOL_SIZE, height: ICON_BUTTON_SYMBOL_SIZE)
        }
    }
}
