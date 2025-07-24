import SwiftUI

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header fisso con immagine hero
            ZStack(alignment: .topLeading) {
                Image("palermo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .clipped()

                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                    
                    Spacer()
                    
                    // Share button
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 40)
            }
            
            // Informazioni evento fisse
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Name")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                        Text("Event Place")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Info cards
                HStack(spacing: 12) {
                    InfoCard(
                        icon: "calendar",
                        title: "Date",
                        subtitle: "Event Date",
                        color: .blue
                    )
                    
                    InfoCard(
                        icon: "creditcard",
                        title: "Price",
                        subtitle: "Event Price",
                        color: .green
                    )
                }
                
                Divider()
                    .padding(.vertical, 2)
            }
            .padding(.horizontal, 15)
            .padding(.top, 24)
            .padding(.bottom, 16)
            .background(Color(.systemBackground))
            
            // ScrollView solo per i dettagli
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Details")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Lorem ipsum dolor sit amet. Qui minus explicabo ex ducimus mollitia aut praesentium culpa eos ipsa cupiditate et quod alias et corrupti asperiores hic esse aspernatur. Et voluptas quam aut voluptates rerum ut possimus repudiandae sed aliquid earum est labore commodi rem dolorem blanditiis. Sed nobis voluptates eum deserunt quae et esse velit eum placeat veritatis ut repellat numquam aut nobis labore. Eos culpa eveniet sed vitae galisum qui dolor dolorum aut perferendis adipisci et distinctio maxime ex praesentium maiores est tempora voluptatem? Quo aperiam maiores est natus ullam rem animi voluptate aut suscipit assumenda ea voluptatem dolor et voluptate maiores! Ad optio nihil rem corrupti rerum ut laudantium deleniti et magnam commodi..")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 15)
                
            }
            .padding(.bottom, 10)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    EventDetailView()
}
