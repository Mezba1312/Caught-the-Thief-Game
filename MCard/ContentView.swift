import SwiftUI

struct ContentView: View {
    @State private var totalPlayers = 4
    @State private var offlinePlayerCount = 1
    @State private var playerRoles = ["King", "Police", "Robber", "Thief"]
    @State private var playerCards = ["", "", "", ""]
    @State private var playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"]
    @State private var scores = [0, 0, 0, 0]
    @State private var showPoliceGuessPrompt = false
    @State private var gameEnded = false
    @State private var policeIndex = -1
    @State private var thiefIndex = -1
    @State private var robberIndex = -1
    @State private var isGameStarted = false
    @State private var currentPlayerIndex = 0
    @State private var guessingPlayerIndex = -1
    @State private var isGuessingInProgress = false
    @State private var revealCards = false
    @State private var guessButtonDisabled = false
    @State private var guessedThief = ""
    @State private var roundNumber = 1
    @State private var isExitAlertPresented = false
    @State private var showOnlyKingAndPolice = false
    @State private var floatingMessage: String? = nil

    var body: some View {
        ZStack {
            Color.indigo.opacity(0.1).ignoresSafeArea()

            if !isGameStarted {
                setupView
            } else {
                gameView
            }

            if let message = floatingMessage {
                Text(message)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .transition(.opacity)
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            floatingMessage = nil
                        }
                    }
            }
        }
        .foregroundColor(.black)
        .alert("Game Over", isPresented: $gameEnded) {
            Button("OK") { resetGame() }
        } message: {
            Text("\(playerNames[winningPlayerIndex()]) wins the game!")
        }
        .alert("Are you sure you want to exit?", isPresented: $isExitAlertPresented) {
            Button("Cancel", role: .cancel) { isExitAlertPresented = false }
            Button("Exit", role: .destructive) { exit(0) }
        }
    }

    private var setupView: some View {
        VStack {
            Text("Set Up the Game")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.indigo)
                .padding(.bottom, 30)

            Text("Choose Offline Players:")
            Picker("Offline Players", selection: $offlinePlayerCount) {
                ForEach(1...4, id: \.self) { count in
                    Text("\(count) Offline Player\(count > 1 ? "s" : "")").tag(count)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            ForEach(0..<offlinePlayerCount, id: \.self) { i in
                TextField("Enter name for Player \(i + 1)", text: $playerNames[i])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            Button("Start Game") {
                setupPlayers()
                isGameStarted = true
            }
            .font(.title2)
            .padding()
            .background(Color.indigo)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private var gameView: some View {
        VStack(spacing: 20) {
            Text("Police caught the Thief!")
                .font(.headline.weight(.semibold))
                .padding()

            Text("Round: \(roundNumber)")
                .font(.title2.weight(.bold))
                .foregroundColor(.orange)
                .padding(.bottom, 5)

            HStack {
                playerInfoView(index: 0)
                Spacer()
                playerInfoView(index: 1)
            }
            .padding()

            Spacer()

            Button(action: deal) {
                Text("Deal Cards")
                    .font(.title2)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isGuessingInProgress || guessButtonDisabled)
            .animation(.easeInOut, value: isGuessingInProgress || guessButtonDisabled)

            Spacer()

            HStack {
                playerInfoView(index: 2)
                Spacer()
                playerInfoView(index: 3)
            }
            .padding()

            if policeIndex != -1 && !guessButtonDisabled {
                guessOptionsView
            }

            if isGuessingInProgress && guessingPlayerIndex != -1 {
                Text("\(playerNames[guessingPlayerIndex]) is guessing the Thief...")
                    .font(.headline)
                    .padding()
            }

            if revealCards {
                Text("\(playerNames[policeIndex]) guessed \(guessedThief) as the Thief")
                    .font(.title3.weight(.semibold))
                    .padding()
                    .foregroundColor(.orange)
            }

            Button("Exit Game") {
                isExitAlertPresented = true
            }
            .font(.title2)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    private func playerInfoView(index: Int) -> some View {
        VStack {
            Text(playerNames[index])
                .font(.headline)
            Text("Score: \(scores[index])")
                .font(.title3)
            Image(playerCards[index].isEmpty || (showOnlyKingAndPolice && index != policeIndex && index != playerRoles.firstIndex(of: "King")) ? "cardBack" : playerCards[index])
                .resizable()
                .frame(width: 60, height: 90)
                .padding(.top, 5)
        }
    }
    
    private var guessOptionsView: some View {
        VStack {
            if policeIndex < offlinePlayerCount {
                Text("\(playerNames[policeIndex]) choose the Thief")
                    .font(.headline)
                    .padding()
                
                ForEach([thiefIndex, robberIndex].filter { $0 != -1 }, id: \.self) { index in
                    Button(playerNames[index]) {
                        policeGuess(thief: playerNames[index])
                    }
                    .font(.title2)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                Text("Computer \(policeIndex + 1) guessed \(playerNames[thiefIndex]) as the Thief")
                    .font(.headline)
                    .padding()
                if guessedThief == playerNames[thiefIndex] {
                    Text("The guess is correct!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                } else {
                    Text("The guess is wrong!")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
    }

    private func setupPlayers() {
        for i in offlinePlayerCount..<4 {
            playerNames[i] = "Computer \(i - offlinePlayerCount + 1)"
        }
    }

    private func deal() {
        if isGuessingInProgress || guessButtonDisabled { return }

        // Reset all round states
        revealCards = false
        isGuessingInProgress = false
        guessButtonDisabled = false
        guessedThief = ""
        showOnlyKingAndPolice = true

        // Shuffle roles and assign cards for new round
        playerRoles.shuffle()
        playerCards = playerRoles.map { role in
            switch role {
            case "King": return "king"
            case "Police": return "police"
            case "Robber": return "robber"
            case "Thief": return "thief"
            default: return "cardBack"
            }
        }

        // Assign indexes based on roles
        policeIndex = playerRoles.firstIndex(of: "Police") ?? -1
        thiefIndex = playerRoles.firstIndex(of: "Thief") ?? -1
        robberIndex = playerRoles.firstIndex(of: "Robber") ?? -1

        // Increase score for King role
        if let kingIndex = playerRoles.firstIndex(of: "King") {
            scores[kingIndex] += 1200
        }

        roundNumber += 1
        currentPlayerIndex = (currentPlayerIndex + 1) % totalPlayers

        // Check for the end of the game
        if scores.contains(where: { $0 >= 5000 }) {
            gameEnded = true
        }

        // Auto-guess if the police is a computer
        if policeIndex >= offlinePlayerCount {
            autoGuessForComputerPolice()
        }
    }

    private func autoGuessForComputerPolice() {
        policeGuess(thief: playerNames[thiefIndex])
    }

    private func policeGuess(thief: String) {
        guessedThief = thief
        revealCards = true
        showOnlyKingAndPolice = false

        if thief == playerNames[thiefIndex] {
            scores[policeIndex] += 900
            showFloatingMessage("\(playerNames[policeIndex]) guessed correctly!")
        } else {
            scores[thiefIndex] += 900
            showFloatingMessage("\(playerNames[policeIndex]) guessed incorrectly!")
        }

        // Additional points for Robber role
        if let robberIndex = playerRoles.firstIndex(of: "Robber") {
            scores[robberIndex] += 400
        }
    }

    private func showFloatingMessage(_ message: String) {
        floatingMessage = message
    }

    private func winningPlayerIndex() -> Int {
        scores.firstIndex(of: scores.max() ?? 0) ?? 0
    }

    private func resetGame() {
        scores = [0, 0, 0, 0]
        roundNumber = 1
        gameEnded = false
        revealCards = false
        isGameStarted = false
    }
}
