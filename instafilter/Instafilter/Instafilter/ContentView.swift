//
//  ContentView.swift
//  Instafilter
//
//  Created by Nick Timmer on 4/23/21.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 0.5
    @State private var filterScale = 0.5
    
    @State private var showingFilterSheet = false
    @State private var showingImagePicker = false
    @State private var filterName = "Sepia Tone"
    
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var showingImageAlert = false
    
    @State var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        let radius = Binding<Double>(
            get: {
                self.filterRadius
            },
            set: {
                self.filterRadius = $0
                self.applyProcessing()
            }
        )
        
        let scale = Binding<Double>(
            get: {
                self.filterScale
            },
            set: {
                self.filterScale = $0
                self.applyProcessing()
            }
        )
        
        
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .background(Color.white)
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }
                
                HStack {
                    Text("Radius   ")
                    Slider(value: radius)
                }
                
                HStack {
                    Text("Scale     ")
                    Slider(value: scale)
                }
                
                
                
                
                HStack {
                    Button(filterName) {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        if image != nil {
                            guard let processedImage = self.processedImage else { return }
                            
                            let imageSaver = ImageSaver()
                            
                            imageSaver.successHandler = {
                                print("Success!")
                            }
                            
                            imageSaver.errorHandler = {
                                print("Oops: \($0.localizedDescription)")
                            }
                            
                            imageSaver.writeToPhotoAlbum(image: processedImage)
                        } else {
                            self.showingImageAlert = true
                        }
                    }
                }
                .padding(.vertical)
                .alert(isPresented: $showingImageAlert) {
                    Alert(title: Text("No Image"), message: Text("You must select an image before you can save"))
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize()); self.filterName = "Crystallize" },
                    .default(Text("Edges")) { self.setFilter(CIFilter.edges()); self.filterName = "Edges" },
                    .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur()); self.filterName = "Gaussian Blur" },
                    .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate()); self.filterName = "Pixellate" },
                    .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone()); self.filterName = "Sepia Tone" },
                    .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask()); self.filterName = "Unsharp Mask" },
                    .default(Text("Vignette")) { self.setFilter(CIFilter.vignette()); self.filterName = "Vignette" },
                    .cancel()
                ])
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beingImage = CIImage(image: inputImage)
        currentFilter.setValue(beingImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
