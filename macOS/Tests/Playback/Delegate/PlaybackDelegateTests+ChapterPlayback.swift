//
//  PlaybackDelegateTests+ChapterPlayback.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackDelegateTests_ChapterPlayback: PlaybackDelegateTestCase {

    private func createChapters(_ count: Int) -> [Chapter] {

        var chapters: [Chapter] = []

        var curTime: Double = 0
        let duration: Double = 60  // 1 minute

        for index in 0..<count {

            chapters.append(Chapter(title: String(format: "Chapter %d", index), startTime: curTime, endTime: curTime + duration))
            curTime += duration
        }

        return chapters
    }

    // MARK: playChapter() tests --------------------------------------------------------------------------------------------

    func testPlayChapter_noTrackPlaying() {

        assertNoTrack()

        player.reset()
        delegate.playChapter(0)

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertNoTrack()
    }

    func testPlayChapter_trackPlaying_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        player.reset()
        delegate.playChapter(0)

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testPlayChapter_trackPlaying_trackHasChapters_validIndices() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        let chapterCount = 10
        track.chapters = createChapters(chapterCount)
        
        player.reset()
        delegate.play(track)

        // Valid indices

        for chapterIndex in 0..<chapterCount {

            delegate.playChapter(chapterIndex)

            XCTAssertEqual(player.forceSeekToTimeCallCount, chapterIndex + 1)
            XCTAssertEqual(player.forceSeekToTime_time!, track.chapters[chapterIndex].startTime, accuracy: 0.02)
            assertPlayingTrack(track)
        }
    }

    func testPlayChapter_trackPlaying_trackHasChapters_invalidIndices() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        let chapterCount = 10
        track.chapters = createChapters(chapterCount)
        delegate.play(track)

        // Invalid indices

        for chapterIndex in chapterCount...(chapterCount + 5) {

            player.reset()
            delegate.playChapter(chapterIndex)

            XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
            assertPlayingTrack(track)
        }
    }

    func testPlayChapter_trackPaused_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        delegate.togglePlayPause()
        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        player.reset()
        delegate.playChapter(0)

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testPlayChapter_trackPaused_trackHasChapters_validIndices() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        let chapterCount = 10
        track.chapters = createChapters(chapterCount)
        delegate.play(track)

        delegate.togglePlayPause()
        assertPausedTrack(track)

        // Valid indices

        for chapterIndex in 0..<chapterCount {

            delegate.playChapter(chapterIndex)

            XCTAssertEqual(player.forceSeekToTimeCallCount, chapterIndex + 1)
            XCTAssertEqual(player.forceSeekToTime_time!, track.chapters[chapterIndex].startTime, accuracy: 0.02)
            assertPlayingTrack(track)
        }
    }

    func testPlayChapter_trackPaused_trackHasChapters_invalidIndices() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        let chapterCount = 10
        track.chapters = createChapters(chapterCount)
        delegate.play(track)

        delegate.togglePlayPause()
        assertPausedTrack(track)

        // Invalid indices

        for chapterIndex in chapterCount...(chapterCount + 5) {

            player.reset()
            delegate.playChapter(chapterIndex)

            XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
            assertPausedTrack(track)
        }
    }

    // MARK: previousChapter() tests --------------------------------------------------------------------------------------------

    func testPreviousChapter_noTrackPlaying() {

        assertNoTrack()

        player.reset()
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertNoTrack()
    }

    private func seekToChapter(_ index: Int) {

        let chapter = delegate.playingTrack!.chapters[index]
        let seekToTime = (chapter.startTime + chapter.endTime) / 2

        delegate.seekToTime(seekToTime)
        mockPlayerNode._seekPosition = seekToTime
    }

    func testPreviousChapter_trackPlaying_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        player.reset()
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testPreviousChapter_trackPlaying_playingBeforeFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 240, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position before the first chapter
        mockPlayerNode._seekPosition = 5

        player.reset()
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testPreviousChapter_trackPlaying_playingFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        seekToChapter(0)

        player.reset()
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testPreviousChapter_trackPlaying_playingMiddleChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        let playingChapter = 4
        seekToChapter(playingChapter)

        doPreviousChapter(playingChapter - 1)
    }

    func testPreviousChapter_trackPlaying_playingBetweenMiddleChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position between chapter 1 and 2
        mockPlayerNode._seekPosition = 245

        doPreviousChapter(1)
    }

    func testPreviousChapter_trackPlaying_playingLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)

        player.reset()
        doPreviousChapter(lastChapterIndex - 1)
    }

    func testPreviousChapter_trackPlaying_playingAfterLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 510))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position after the last chapter
        mockPlayerNode._seekPosition = 550

        doPreviousChapter(track.chapters.count - 1)
    }

    func testPreviousChapter_trackPaused_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testPreviousChapter_trackPaused_playingBeforeFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 240, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position before the first chapter
        mockPlayerNode._seekPosition = 5

        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testPreviousChapter_trackPaused_playingFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        seekToChapter(0)

        player.reset()
        delegate.previousChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testPreviousChapter_trackPaused_playingMiddleChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        let playingChapter = 4
        seekToChapter(playingChapter)

        doPreviousChapter(playingChapter - 1)
    }

    func testPreviousChapter_trackPaused_playingBetweenMiddleChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position between chapter 1 and 2
        mockPlayerNode._seekPosition = 245

        doPreviousChapter(1)
    }

    func testPreviousChapter_trackPaused_playingLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)

        doPreviousChapter(lastChapterIndex - 1)
    }

    func testPreviousChapter_trackPaused_playingAfterLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 510))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position after the last chapter
        mockPlayerNode._seekPosition = 550

        doPreviousChapter(track.chapters.count - 1)
    }

    private func doPreviousChapter(_ expectedChapterIndex: Int) {
        
        player.reset()

        let track = delegate.playingTrack!

        delegate.previousChapter()

        let startTimeOfPreviousChapter = track.chapters[expectedChapterIndex].startTime

        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_time!, startTimeOfPreviousChapter, accuracy: 0.02)

        assertPlayingTrack(track)
    }

    // MARK: nextChapter() tests --------------------------------------------------------------------------------------------

    func testNextChapter_noTrackPlaying() {

        assertNoTrack()

        player.reset()
        delegate.nextChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertNoTrack()
    }

    func testNextChapter_trackPlaying_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        player.reset()
        delegate.nextChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testNextChapter_trackPlaying_playingBeforeFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 240, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position before the first chapter
        mockPlayerNode._seekPosition = 5

        doNextChapter(0)
    }

    func testNextChapter_trackPlaying_playingFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        seekToChapter(0)

        doNextChapter(1)
    }

    func testNextChapter_trackPlaying_playingMiddleChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        let playingChapter = 4
        seekToChapter(playingChapter)

        doNextChapter(playingChapter + 1)
    }

    func testNextChapter_trackPlaying_playingBetweenMiddleChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position between chapter 1 and 2
        mockPlayerNode._seekPosition = 245

        doNextChapter(2)
    }

    func testNextChapter_trackPlaying_playingLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)

        player.reset()
        delegate.nextChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testNextChapter_trackPlaying_playingAfterLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 510))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position after the last chapter
        mockPlayerNode._seekPosition = 550

        player.reset()
        delegate.nextChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testNextChapter_trackPaused_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        player.reset()
        delegate.nextChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testNextChapter_trackPaused_playingBeforeFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 240, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position before the first chapter
        mockPlayerNode._seekPosition = 5

        doNextChapter(0)
    }

    func testNextChapter_trackPaused_playingFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        seekToChapter(0)

        doNextChapter(1)
    }

    func testNextChapter_trackPaused_playingMiddleChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        let playingChapter = 4
        seekToChapter(playingChapter)

        doNextChapter(playingChapter + 1)
    }

    func testNextChapter_trackPaused_playingBetweenMiddleChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position between chapter 1 and 2
        mockPlayerNode._seekPosition = 245

        doNextChapter(2)
    }

    func testNextChapter_trackPaused_playingLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)

        player.reset()
        delegate.nextChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testNextChapter_trackPaused_playingAfterLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 510))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position after the last chapter
        mockPlayerNode._seekPosition = 550

        player.reset()
        delegate.nextChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    private func doNextChapter(_ expectedChapterIndex: Int) {
        
        player.reset()

        let track = delegate.playingTrack!

        delegate.nextChapter()

        let startTimeOfNextChapter = track.chapters[expectedChapterIndex].startTime

        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_time!, startTimeOfNextChapter, accuracy: 0.02)

        assertPlayingTrack(track)
    }

    // MARK: replayChapter() tests --------------------------------------------------------------------------------------------

    func testReplayChapter_noTrackPlaying() {

        assertNoTrack()

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertNoTrack()
    }

    func testReplayChapter_trackPlaying_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testReplayChapter_trackPlaying_playingBeforeFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 240, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position before the first chapter
        mockPlayerNode._seekPosition = 5

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testReplayChapter_trackPlaying_playingBetweenMiddleChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position between chapter 1 and 2
        mockPlayerNode._seekPosition = 245

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testReplayChapter_trackPlaying_playingAfterLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 510))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position after the last chapter
        mockPlayerNode._seekPosition = 550

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPlayingTrack(track)
    }

    func testReplayChapter_trackPlaying_playingFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        seekToChapter(0)

        doReplayChapter(0)
    }

    func testReplayChapter_trackPlaying_playingMiddleChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        let playingChapter = 4
        seekToChapter(playingChapter)

        doReplayChapter(playingChapter)
    }

    func testReplayChapter_trackPlaying_playingLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)

        doReplayChapter(lastChapterIndex)
    }

    func testReplayChapter_trackPaused_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testReplayChapter_trackPaused_playingBeforeFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 240, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position before the first chapter
        mockPlayerNode._seekPosition = 5

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testReplayChapter_trackPaused_playingBetweenMiddleChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position between chapter 1 and 2
        mockPlayerNode._seekPosition = 245

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testReplayChapter_trackPaused_playingAfterLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 510))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position after the last chapter
        mockPlayerNode._seekPosition = 550

        player.reset()
        delegate.replayChapter()

        XCTAssertEqual(player.forceSeekToTimeCallCount, 0)
        assertPausedTrack(track)
    }

    func testReplayChapter_trackPaused_playingFirstChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        seekToChapter(0)

        doReplayChapter(0)
    }

    func testReplayChapter_trackPaused_playingMiddleChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        let playingChapter = 4
        seekToChapter(playingChapter)

        doReplayChapter(playingChapter)
    }

    func testReplayChapter_trackPaused_playingLastChapter() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        // Seek to last chapter
        let lastChapterIndex = track.chapters.count - 1
        seekToChapter(lastChapterIndex)

        doReplayChapter(lastChapterIndex)
    }

    private func doReplayChapter(_ chapterIndex: Int) {
        
        player.reset()

        let track = delegate.playingTrack!

        delegate.replayChapter()

        let chapterStartTime = track.chapters[chapterIndex].startTime

        XCTAssertEqual(player.forceSeekToTimeCallCount, 1)
        XCTAssertEqual(player.forceSeekToTime_time!, chapterStartTime, accuracy: 0.02)

        assertPlayingTrack(track)
    }

    // MARK: loopChapter() tests --------------------------------------------------------------------------------------------

    func testToggleChapterLoop_noTrackPlaying() {

        assertNoTrack()
        player.reset()

        let loopExists = delegate.toggleChapterLoop()
        XCTAssertFalse(loopExists)

        XCTAssertEqual(player.defineLoopCallCount, 0)
        XCTAssertNil(delegate.playbackLoop)
        assertNoTrack()
    }

    func testToggleChapterLoop_trackPlaying_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)
        player.reset()

        let loopExists = delegate.toggleChapterLoop()
        XCTAssertFalse(loopExists)

        XCTAssertEqual(player.defineLoopCallCount, 0)
        XCTAssertNil(delegate.playbackLoop)
        assertPlayingTrack(track)
    }

    func testToggleChapterLoop_trackPlaying_playingBetweenChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position between chapter 1 and 2
        mockPlayerNode._seekPosition = 245
        player.reset()

        let loopExists = delegate.toggleChapterLoop()
        XCTAssertFalse(loopExists)

        XCTAssertEqual(player.defineLoopCallCount, 0)
        XCTAssertNil(delegate.playbackLoop)
        assertPlayingTrack(track)
    }

    func testToggleChapterLoop_trackPlaying_playingChapter_noPredefinedLoop() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, track.chapters.count)

        for chapterIndex in 0..<delegate.chapterCount {

            XCTAssertNil(delegate.playbackLoop)

            // Seek to chapter and define the chapter loop
            seekToChapter(chapterIndex)
            doLoopChapter(chapterIndex)

            assertPlayingTrack(track)

            // After each test iteration, remove the chapter loop
            XCTAssertNil(delegate.toggleLoop())
        }
    }

    func testToggleChapterLoop_trackPlaying_playingChapter_predefinedLoopStarted() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, track.chapters.count)
        
        for chapterIndex in 0..<delegate.chapterCount {
            
            XCTAssertNil(delegate.playbackLoop)

            // Begin a predefined loop
            mockPlayerNode._seekPosition = .random(in: 0...(track.duration / 2))
            let loop = delegate.toggleLoop()
            XCTAssertFalse(loop!.isComplete)

            // Seek to chapter and define the chapter loop
            seekToChapter(chapterIndex)
            doLoopChapter(chapterIndex)

            assertPlayingTrack(track)

            // After each test iteration, remove the chapter loop
            XCTAssertNil(delegate.toggleLoop())
        }
    }

    func testToggleChapterLoop_trackPlaying_playingChapter_predefinedLoopComplete() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, track.chapters.count)

        for chapterIndex in 0..<delegate.chapterCount {

            XCTAssertNil(delegate.playbackLoop)

            // Begin a predefined loop
            mockPlayerNode._seekPosition = .random(in: 0..<(track.duration / 2))
            var loop = delegate.toggleLoop()
            XCTAssertFalse(loop!.isComplete)

            // Complete the predefined loop
            mockPlayerNode._seekPosition = .random(in: (track.duration / 2)..<track.duration)
            loop = delegate.toggleLoop()
            XCTAssertTrue(loop!.isComplete)

            // Seek to chapter and define the chapter loop
            seekToChapter(chapterIndex)
            doLoopChapter(chapterIndex)

            assertPlayingTrack(track)

            // After each test iteration, remove the chapter loop
            XCTAssertNil(delegate.toggleLoop())
        }
    }

    func testToggleChapterLoop_trackPaused_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        player.reset()
        let loopExists = delegate.toggleChapterLoop()
        XCTAssertFalse(loopExists)

        XCTAssertEqual(player.defineLoopCallCount, 0)
        XCTAssertNil(delegate.playbackLoop)
        assertPausedTrack(track)
    }

    func testToggleChapterLoop_trackPaused_playingBetweenChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)

        var chapters: [Chapter] = []
        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))
        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 60, endTime: 240))
        chapters.append(Chapter(title: "Chapter 2 - Presence", startTime: 250, endTime: 600))

        track.chapters = chapters

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, chapters.count)

        // Seek to a position between chapter 1 and 2
        mockPlayerNode._seekPosition = 245
        player.reset()

        let loopExists = delegate.toggleChapterLoop()
        XCTAssertFalse(loopExists)

        XCTAssertEqual(player.defineLoopCallCount, 0)
        XCTAssertNil(delegate.playbackLoop)
        assertPausedTrack(track)
    }

    func testToggleChapterLoop_trackPaused_playingChapter_noPredefinedLoop() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, track.chapters.count)

        for chapterIndex in 0..<delegate.chapterCount {

            XCTAssertNil(delegate.playbackLoop)

            // Seek to chapter and define the chapter loop
            seekToChapter(chapterIndex)
            doLoopChapter(chapterIndex)

            assertPausedTrack(track)

            // After each test iteration, remove the chapter loop
            XCTAssertNil(delegate.toggleLoop())
        }
    }

    func testToggleChapterLoop_trackPaused_playingChapter_predefinedLoopStarted() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, track.chapters.count)

        for chapterIndex in 0..<delegate.chapterCount {

            XCTAssertNil(delegate.playbackLoop)

            // Begin a predefined loop
            mockPlayerNode._seekPosition = .random(in: 0...(track.duration / 2))
            let loop = delegate.toggleLoop()
            XCTAssertFalse(loop!.isComplete)

            // Seek to chapter and define the chapter loop
            seekToChapter(chapterIndex)
            doLoopChapter(chapterIndex)

            assertPausedTrack(track)

            // After each test iteration, remove the chapter loop
            XCTAssertNil(delegate.toggleLoop())
        }
    }

    func testToggleChapterLoop_trackPaused_playingChapter_predefinedLoopComplete() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)

        delegate.play(track)
        delegate.togglePlayPause()

        assertPausedTrack(track)
        XCTAssertEqual(delegate.chapterCount, track.chapters.count)

        for chapterIndex in 0..<delegate.chapterCount {

            XCTAssertNil(delegate.playbackLoop)

            // Begin a predefined loop
            mockPlayerNode._seekPosition = .random(in: 0..<(track.duration / 2))
            var loop = delegate.toggleLoop()
            XCTAssertFalse(loop!.isComplete)

            // Complete the predefined loop
            mockPlayerNode._seekPosition = .random(in: (track.duration / 2)..<track.duration)
            loop = delegate.toggleLoop()
            XCTAssertTrue(loop!.isComplete)

            // Seek to chapter and define the chapter loop
            seekToChapter(chapterIndex)
            doLoopChapter(chapterIndex)

            assertPausedTrack(track)

            // After each test iteration, remove the chapter loop
            XCTAssertNil(delegate.toggleLoop())
        }
    }

    private func doLoopChapter(_ chapterIndex: Int) {

        let track = delegate.playingTrack!
        let defineLoopCallCountBefore: Int = player.defineLoopCallCount

        let loopExists = delegate.toggleChapterLoop()
        XCTAssertTrue(loopExists)

        XCTAssertEqual(player.defineLoopCallCount, defineLoopCallCountBefore + 1)
        XCTAssertEqual(player.defineLoop_startTime!, track.chapters[chapterIndex].startTime, accuracy: 0.0011)
        XCTAssertEqual(player.defineLoop_endTime!, track.chapters[chapterIndex].endTime, accuracy: 0.0011)

        let loop = delegate.playbackLoop
        XCTAssertTrue(loop!.isComplete)
        XCTAssertEqual(loop!.startTime, track.chapters[chapterIndex].startTime, accuracy: 0.0011)
        XCTAssertEqual(loop!.endTime!, track.chapters[chapterIndex].endTime, accuracy: 0.0011)
    }

    // MARK: chapterCount tests --------------------------------------------------------------------------------------------

    func testChapterCount_noTrack() {

        delegate.stop()
        XCTAssertNil(delegate.playingTrack)

        XCTAssertEqual(delegate.chapterCount, 0)
    }

    func testChapterCount_playing_noChapters() {

        let track = createTrack(title: "So Far Away", duration: 300)
        track.chapters = []

        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)

        XCTAssertEqual(delegate.chapterCount, 0)
    }

    func testChapterCount_playing_hasChapters() {

        let track = createTrack(title: "So Far Away", duration: 300)
        delegate.play(track)
        XCTAssertEqual(delegate.playingTrack!, track)

        for numChapters in 1...100 {

            track.chapters = createChapters(numChapters)
            XCTAssertEqual(track.chapters.count, numChapters)

            XCTAssertEqual(delegate.chapterCount, track.chapters.count)
        }
    }

    // MARK: playingChapter tests -------------------------------------------------------------------------------

    func testPlayingChapter_noTrackPlaying() {

        assertNoTrack()
        XCTAssertNil(delegate.playingChapter)
    }

    func testPlayingChapter_trackPlaying_noChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        XCTAssertEqual(track.chapters.count, 0)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 0)

        XCTAssertNil(delegate.playingChapter)
    }

    func testPlayingChapter_trackPlaying_hasContiguousChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 600)
        track.chapters = createChapters(10)
        XCTAssertEqual(track.chapters.count, 10)

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 10)

        for index in 0..<delegate.chapterCount {

            seekToChapter(index)
            doComparePlayingChapter(track, index, track.chapters[index])
        }
    }

    func testPlayingChapter_trackPlaying_gapsBetweenChapters() {

        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 3600)

        var chapters: [Chapter] = []

        chapters.append(Chapter(title: "Introduction", startTime: 10, endTime: 60))

        chapters.append(Chapter(title: "Chapter 1 - Unconsciousness", startTime: 70, endTime: 1040))
        chapters.append(Chapter(title: "Chapter 2 - Seeing the madness", startTime: 1040, endTime: 1200))

        chapters.append(Chapter(title: "Chapter 3 - Choosing not to participate", startTime: 1205, endTime: 2400))
        chapters.append(Chapter(title: "Chapter 4 - Life purpose", startTime: 2400, endTime: 3500))

        track.chapters = chapters

        delegate.play(track)
        assertPlayingTrack(track)
        XCTAssertEqual(delegate.chapterCount, 5)

        // Seek to position in the gap before chapters[0]
        mockPlayerNode._seekPosition = 4.5
        XCTAssertNil(delegate.playingChapter)

        // Seek to position in the gap between chapters[0] and chapters[1]
        mockPlayerNode._seekPosition = 62.7438579345
        XCTAssertNil(delegate.playingChapter)

        // Seek to position in the gap between chapters[2] and chapters[3]
        mockPlayerNode._seekPosition = 1201.12002193
        XCTAssertNil(delegate.playingChapter)

        // Seek to position in the gap after chapters[4]
        mockPlayerNode._seekPosition = 3576.2314242528
        XCTAssertNil(delegate.playingChapter)

        for index in 0..<delegate.chapterCount {

            seekToChapter(index)
            doComparePlayingChapter(track, index, track.chapters[index])
        }
    }

    private func doComparePlayingChapter(_ track: Track, _ index: Int, _ chapter: Chapter) {

        let playingChapter = delegate.playingChapter!

        XCTAssertEqual(playingChapter.track, track)
        XCTAssertEqual(playingChapter.index, index)

        XCTAssertEqual(playingChapter.chapter.title, chapter.title)
        XCTAssertEqual(playingChapter.chapter.startTime, chapter.startTime, accuracy: 0.001)
        XCTAssertEqual(playingChapter.chapter.endTime, chapter.endTime, accuracy: 0.001)
    }

    // playingChapter needs to be efficient because it is repeatedly called to keep track of the current chapter
    func testPlayingChapterPerformance() {

        // Simulate a 10-hour-long audiobook with 100 chapters
        let track = createTrack(title: "Eckhart Tolle - Art of Presence", duration: 36000)
        track.chapters = createChapters(100)
        XCTAssertEqual(track.chapters.count, 100)

        delegate.play(track)
        XCTAssertEqual(delegate.chapterCount, track.chapters.count)

        let maxExecTime_msec: Double = 2
        var totalExecTime: Double = 0
        var callCount: Int = 0

        // Reset the seek position to the beginning of the track.
        // The seek position will be incremented throughout the test to simulate playback of the track
        mockPlayerNode._seekPosition = 0

        // Repeat till the seek position reaches the end of the track
        while mockPlayerNode.seekPosition < track.duration {

            totalExecTime += executionTimeFor {
                _ = delegate.playingChapter
            }

            // Increment the seek position by half a second to match the app's seek timer interval
            mockPlayerNode._seekPosition += 0.5
            callCount.increment()
        }

        let avgExecTime: Double = totalExecTime / Double(callCount)
        XCTAssertLessThan(avgExecTime, maxExecTime_msec / 1000.0)
    }
}
