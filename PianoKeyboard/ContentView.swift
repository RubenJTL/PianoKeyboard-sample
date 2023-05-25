//
//  ContentView.swift
//  PianoKeyboard
//
//  Created by Ruben Torres on 20/05/23.
//

import Keyboard
import SwiftUI
import Tonic
import AudioKit
import SoundpipeAudioKit
import AudioKitEX

class AmplitudeEnvelopeConductor: ObservableObject, HasAudioEngine {
    let engine = AudioEngine()
    var currentNote = 0

    func noteOn(pitch: Pitch, point _: CGPoint) {
        if pitch.midiNoteNumber != currentNote {
            env.closeGate()
        }
        osc.frequency = AUValue(pitch.midiNoteNumber).midiNoteToFrequency()
        env.openGate()
    }

    func noteOff(pitch _: Pitch) {
        env.closeGate()
    }

    var osc: Oscillator
    var env: AmplitudeEnvelope
    var fader: Fader

    init() {
        osc = Oscillator()
        env = AmplitudeEnvelope(osc)
        fader = Fader(env)
        osc.amplitude = 1
        engine.output = fader
    }

    func start() {
        osc.start()
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        osc.stop()
        engine.stop()
    }
}

struct ContentView: View {
    @StateObject var conductor = AmplitudeEnvelopeConductor()

    @State var lowNote = 57
    @State var highNote = 77

    var body: some View {
        VStack {
            Text("Piano")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 50)

            Keyboard(layout: .piano(pitchRange: Pitch(intValue: lowNote) ... Pitch(intValue: highNote)),
                     noteOn: conductor.noteOn, noteOff: conductor.noteOff) { pitch, isPressed in
                Group {
                    if isBlackKey(pitch: pitch) {
                        if isPressed {
                            Image("Pressed")
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image("NoPressed")
                                .resizable()
                                .scaledToFill()
                        }
                    } else {
                        if isPressed {
                            Image("EvonyPressed")
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image("EvonyNoPressed")
                                .resizable()
                                .scaledToFill()
                        }
                    }

                }
                .overlay(alignment: .bottom) {
                    Text(noteText(pitch: pitch))
                }
                .allowsHitTesting(true)
            }
        }
        .onAppear {
            conductor.start()
        }
        .onDisappear {
            conductor.stop()
        }
    }

    func noteText(pitch: Pitch) -> String {
        if pitch.note(in: .C).noteClass.letter == .C {
            return pitch.note(in: .C).description
        }

        return ""
    }

    func isBlackKey(pitch: Pitch) -> Bool {
        return pitch.note(in: .C).noteClass.accidental == .sharp
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
