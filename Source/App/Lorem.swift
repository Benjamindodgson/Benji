//
//  Lorem.swift
//  Benji
//
//  Created by Benji Dodgson on 6/29/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class Lorem {

    private static let wordList = [
        "alias", "consequatur", "aut", "perferendis", "sit", "voluptatem",
        "accusantium", "doloremque", "aperiam", "eaque", "ipsa", "quae", "ab",
        "illo", "inventore", "veritatis", "et", "quasi", "architecto",
        "beatae", "vitae", "dicta", "sunt", "explicabo", "aspernatur", "aut",
        "odit", "aut", "fugit", "sed", "quia", "consequuntur", "magni",
        "dolores", "eos", "qui", "ratione", "voluptatem", "sequi", "nesciunt",
        "neque", "dolorem", "ipsum", "quia", "dolor", "sit", "amet",
        "consectetur", "adipisci", "velit", "sed", "quia", "non", "numquam",
        "eius", "modi", "tempora", "incidunt", "ut", "labore", "et", "dolore",
        "magnam", "aliquam", "quaerat", "voluptatem", "ut", "enim", "ad",
        "minima", "veniam", "quis", "nostrum", "exercitationem", "ullam",
        "corporis", "nemo", "enim", "ipsam", "voluptatem", "quia", "voluptas",
        "sit", "suscipit", "laboriosam", "nisi", "ut", "aliquid", "ex", "ea",
        "commodi", "consequatur", "quis", "autem", "vel", "eum", "iure",
        "reprehenderit", "qui", "in", "ea", "voluptate", "velit", "esse",
        "quam", "nihil", "molestiae", "et", "iusto", "odio", "dignissimos",
        "ducimus", "qui", "blanditiis", "praesentium", "laudantium", "totam",
        "rem", "voluptatum", "deleniti", "atque", "corrupti", "quos",
        "dolores", "et", "quas", "molestias", "excepturi", "sint",
        "occaecati", "cupiditate", "non", "provident", "sed", "ut",
        "perspiciatis", "unde", "omnis", "iste", "natus", "error",
        "similique", "sunt", "in", "culpa", "qui", "officia", "deserunt",
        "mollitia", "animi", "id", "est", "laborum", "et", "dolorum", "fuga",
        "et", "harum", "quidem", "rerum", "facilis", "est", "et", "expedita",
        "distinctio", "nam", "libero", "tempore", "cum", "soluta", "nobis",
        "est", "eligendi", "optio", "cumque", "nihil", "impedit", "quo",
        "porro", "quisquam", "est", "qui", "minus", "id", "quod", "maxime",
        "placeat", "facere", "possimus", "omnis", "voluptas", "assumenda",
        "est", "omnis", "dolor", "repellendus", "temporibus", "autem",
        "quibusdam", "et", "aut", "consequatur", "vel", "illum", "qui",
        "dolorem", "eum", "fugiat", "quo", "voluptas", "nulla", "pariatur",
        "at", "vero", "eos", "et", "accusamus", "officiis", "debitis", "aut",
        "rerum", "necessitatibus", "saepe", "eveniet", "ut", "et",
        "voluptates", "repudiandae", "sint", "et", "molestiae", "non",
        "recusandae", "itaque", "earum", "rerum", "hic", "tenetur", "a",
        "sapiente", "delectus", "ut", "aut", "reiciendis", "voluptatibus",
        "maiores", "doloribus", "asperiores", "repellat"
    ]

    private static let quotes = [#""When I was a boy and I would see scary things in the news, my mother would say to me, "Look for the helpers. You will always find people who are helping.""#,
    #""Love isn’t a state of perfect caring. It is an active noun like struggle. To love someone is to strive to accept that person exactly the way he or she is, right here and now.""#,
    #""If you could only sense how important you are to the lives of those you meet; how important you can be to the people you may never even dream of. There is something of yourself that you leave at every meeting with another person.""#,
    #""It’s not so much what we have in this life that matters. It’s what we do with what we have.""#,
    #""The world needs a sense of worth, and it will achieve it only by its people feeling that they are worthwhile.""#,
    #""We live in a world in which we need to share responsibility. It’s easy to say “It’s not my child, not my community, not my world, not my problem. Then there are those who see the need and respond. I consider those people my heroes.""#,
    #""Nobody else can live the life you live. And even though no human being is perfect, we always have the chance to bring what’s unique about us to live in a redeeming way."#
    ]

    private static let nameList = ["Jane", "Bobby", "Ashley", "Benjamin", "Devon", "Kevin", "Leo"]

    private static let dateList = [Date.subtract(component: .day, amount: 1, toDate: Date())!,
                                   Date.subtract(component: .month, amount: 1, toDate: Date())!,
                                   Date.subtract(component: .second, amount: 30, toDate: Date())!,
                                   Date.subtract(component: .year, amount: 2, toDate: Date())!,
                                   Date.subtract(component: .minute, amount: 10, toDate: Date())!]

    private static let imageList = [UIImage(named: "Profile1")!, UIImage(named: "Profile2")!, UIImage(named: "Profile3")!, UIImage(named: "Profile4")!, UIImage(named: "Profile5")!]

    private static let dates = [Date.easy("07/19/2019"), Date.easy("07/18/2019"), Date.easy("07/16/2019")]

    private static let isFromCurrentUserList = [true, false]


    class func avatar() -> SystemAvatar {
        return SystemAvatar(givenName: self.name(),
                            familyName: self.name(),
                            image: self.image())
    }

    class func systemChannel() -> SystemChannel {
        var avatars: [Avatar] = []
        for _ in 0...3 {
            avatars.append(self.avatar())
        }

        var messages: [SystemMessage] = []
        for _ in 0...50 {
            messages.append(self.systemMessage())
        }

        let channel = SystemChannel(avatars: avatars,
                                    context: self.context(),
                                    id: String(self.randomString()),
                                    timeStampAsDate: self.dates.random(),
                                    messages: messages,
                                    uniqueName: self.channelName())

        return channel 
    }

    class func systemMessage() -> SystemMessage {

        let message = SystemMessage(avatar: self.avatar(),
                                    context: self.context(),
                                    isFromCurrentUser: self.isFromCurrentUserList.random(),
                                    createdAt: self.dates.random(),
                                    authorId: "testMessage",
                                    messageIndex: nil,
                                    status: .sent,
                                    kind: .text(self.sentence()),
                                    id: String(),
                                    attributes: nil)

        return message
    }

    class func systemParagraph() -> SystemMessage {

        let message = SystemMessage(avatar: self.avatar(),
                                    context: self.context(),
                                    isFromCurrentUser: self.isFromCurrentUserList.random(),
                                    createdAt: self.dates.random(),
                                    authorId: "testMessage",
                                    messageIndex: nil,
                                    status: .sent,
                                    kind: .text(self.paragraph()),
                                    id: String(),
                                    attributes: nil)
        return message
    }

    class func randomString(length: Int = 10) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    class func quote() -> String {
        self.quotes.random()
    }

    class func channelName() -> String {
        return self.word()
    }

    class func friendlyName() -> String {
        return "#" + self.wordList.random()
    }

    class func name() -> String {
        return self.nameList.random()
    }

    class func image() -> UIImage {
        return self.imageList.random()
    }

    class func context() -> MessageContext {
        return MessageContext.allCases.random()
    }

    class func date() -> Date {
        return self.dateList.random()
    }

    /**
     Return a random word.

     - returns: Returns a random word.
     */

    class func word() -> String {
        return self.wordList.random()!
    }

    /**
     Return an array of `count` words.

     - parameter count: The number of words to return.

     - returns: Returns an array of `count` words.
     */
    class func words(nbWords: Int = 3) -> [String] {
        return self.wordList.random(nbWords)
    }

    /**
     Return a string of `count` words.

     - parameter count: The number of words the string should contain.

     - returns: Returns a string of `count` words.
     */
    class func words(nbWords: Int = 3) -> String {
        return self.words(nbWords: nbWords).joined(separator: " ")
    }

    /**
     Generate a sentence of `nbWords` words.
     - parameter nbWords:  The number of words the sentence should contain.
     - parameter variable: If `true`, the number of words will vary between
     +/- 40% of `nbWords`.
     - returns:
     */
    class func sentence(nbWords: Int = 6, variable: Bool = true) -> String {
        if nbWords <= 0 {
            return ""
        }

        let result: String = self.words(nbWords: variable ? nbWords.randomize(variation: 40) : nbWords)

        return result.firstCapitalized + "."
    }

    /**
     Generate an array of sentences.
     - parameter nbSentences: The number of sentences to generate.

     - returns: Returns an array of random sentences.
     */
    class func sentences(nbSentences: Int = 3) -> [String] {
        return (0..<nbSentences).map { _ in self.sentence() }
    }

    /**
     Generate a paragraph with `nbSentences` random sentences.
     - parameter nbSentences: The number of sentences the paragraph should
     contain.
     - parameter variable:    If `true`, the number of sentences will vary
     between +/- 40% of `nbSentences`.
     - returns: Returns a paragraph with `nbSentences` random sentences.
     */
    class func paragraph(nbSentences: Int = 3, variable: Bool = true) -> String {
        if nbSentences <= 0 {
            return ""
        }

        return self.sentences(nbSentences: variable ? nbSentences.randomize(variation: 40) : nbSentences).joined(separator: " ")
    }

    /**
     Generate an array of random paragraphs.
     - parameter nbParagraphs: The number of paragraphs to generate.
     - returns: Returns an array of `nbParagraphs` paragraphs.
     */
    class func paragraphs(nbParagraphs: Int = 3) -> [String] {
        return (0..<nbParagraphs).map { _ in paragraph() }
    }

    /**
     Generate a string of random paragrahs.
     - parameter nbParagraphs: The number of paragraphs to generate.
     - returns: Returns a string of random paragraphs.
     */
    class func paragraphs(nbParagraphs: Int = 3) -> String {
        return self.paragraphs(nbParagraphs: nbParagraphs).joined(separator: "\n\n")
    }

    /**
     Generate a string of at most `maxNbChars` characters.
     - parameter maxNbChars: The maximum number of characters the string
     should contain.
     - returns: Returns a string of at most `maxNbChars` characters.
     */
    class func text(maxNbChars: Int = 200) -> String {
        var result: [String] = []

        if maxNbChars < 5 {
            return ""
        } else if maxNbChars < 25 {
            while result.count == 0 {
                var size = 0

                while size < maxNbChars {
                    let w = (size != 0 ? " " : "") + self.word()
                    result.append(w)
                    size += w.count
                }

                _ = result.popLast()
            }
        } else if maxNbChars < 100 {
            while result.count == 0 {
                var size = 0

                while size < maxNbChars {
                    let s = (size != 0 ? " " : "") + self.sentence()
                    result.append(s)
                    size += s.count
                }

                _ = result.popLast()
            }
        } else {
            while result.count == 0 {
                var size = 0

                while size < maxNbChars {
                    let p = (size != 0 ? "\n" : "") + self.paragraph()
                    result.append(p)
                    size += p.count
                }

                _ = result.popLast()
            }
        }

        return result.joined(separator: "")
    }
}

extension String {
    var firstCapitalized: String {
        var string = self
        string.replaceSubrange(string.startIndex...string.startIndex, with: String(string[string.startIndex]).capitalized)
        return string
    }
}

extension Array {
    /**
     Shuffle the array in-place using the Fisher-Yates algorithm.
     */
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if j != i {
                self.swapAt(i, j)
            }
        }
    }

    /**
     Return a shuffled version of the array using the Fisher-Yates
     algorithm.

     - returns: Returns a shuffled version of the array.
     */
    func shuffled() -> [Element] {
        var list = self
        list.shuffle()

        return list
    }

    /**
     Return a random element from the array.
     - returns: Returns a random element from the array or `nil` if the
     array is empty.
     */
    func random() -> Element? {
        return (count > 0) ? self.shuffled()[0] : nil
    }

    /**
     Return a random subset of `cnt` elements from the array.
     - returns: Returns a random subset of `cnt` elements from the array.
     */
    func random(_ count: Int = 1) -> [Element] {
        let result = self.shuffled()

        return (count > result.count) ? result : Array(result[0..<count])
    }
}

extension Int {
    /**
     Return a random number between `min` and `max`.
     - note: The maximum value cannot be more than `UInt32.max - 1`

     - parameter min: The minimum value of the random value (defaults to `0`).
     - parameter max: The maximum value of the random value (defaults to `UInt32.max - 1`)

     - returns: Returns a random value between `min` and `max`.
     */
    static func random(min: Int = 0, max: Int = Int.max) -> Int {
        precondition(min <= max, "attempt to call random() with min > max")

        let diff   = UInt(bitPattern: max &- min)
        let result = UInt.random(min: 0, max: diff)

        return min + Int(bitPattern: result)
    }

    func randomize(variation: Int) -> Int {
        let multiplier = Double(Int.random(min: 100 - variation, max: 100 + variation)) / 100
        let randomized = Double(self) * multiplier

        return Int(randomized) + 1
    }
}

private extension UInt {
    static func random(min: UInt, max: UInt) -> UInt {
        precondition(min <= max, "attempt to call random() with min > max")

        if min == UInt.min && max == UInt.max {
            var result: UInt = 0
            arc4random_buf(&result, MemoryLayout.size(ofValue: result))

            return result
        } else {
            let range         = max - min + 1
            let limit         = UInt.max - UInt.max % range
            var result: UInt = 0

            repeat {
                arc4random_buf(&result, MemoryLayout.size(ofValue: result))
            } while result >= limit

            result = result % range

            return min + result
        }
    }
}
