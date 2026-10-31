import SwiftUI

/// 12 — Camera permission.
///
/// The real prompt is drawn by the system and is never restyled; its copy comes
/// from `NSCameraUsageDescription`. This replica exists so the flow can be seen
/// end to end in previews and design review. In production, replace this overlay
/// with `AVCaptureDevice.requestAccess(for: .video)`.
struct CameraPermissionAlertView: View {
    let onAllow: () -> Void
    let onDeny: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.backgroundTop, Color(hex: 0x0A1620)],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.9)
            .ignoresSafeArea()

            Image(systemName: AppSymbol.faceGuide)
                .font(.system(size: 100, weight: .ultraLight))
                .foregroundStyle(AppColor.accentStart)
                .opacity(0.25)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 146)

            alert
                .padding(.horizontal, 52)
        }
    }

    private var alert: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.xxsPlus) {
                Text(DesignContent.Scan.permissionTitle)
                    .font(AppFont.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(DesignContent.Scan.permissionBody)
                    .font(AppFont.footnote)
                    .lineHeight(1.35, size: 13)
                    .foregroundStyle(.white.opacity(0.82))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.screen)
            .padding(.bottom, Spacing.l)

            Rectangle()
                .fill(.white.opacity(0.22))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                alertButton(DesignContent.Scan.permissionDeny, weight: .regular, action: onDeny)

                Rectangle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 0.5)

                alertButton(DesignContent.Scan.permissionAllow, weight: .semibold, action: onAllow)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(AppColor.systemAlertSurface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.6), radius: 30, y: 24)
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    private func alertButton(
        _ title: String,
        weight: Font.Weight,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: weight))
                .foregroundStyle(AppColor.systemBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.m)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("12 Camera permission") {
    CameraPermissionAlertView(onAllow: {}, onDeny: {})
        .preferredColorScheme(.dark)
}
