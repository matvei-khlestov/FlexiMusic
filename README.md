# FlexiMusic

<p align="center">
  <img
    width="1300"
    height="2050"
    alt="FlexiMusic"
    src="https://github.com/user-attachments/assets/c9f518c8-c337-4438-8fec-2217ad653443"
  />
</p>

FlexiMusic is a demo iOS application that showcases an interactive audio player with swipe-driven expand and collapse behavior, inspired by modern music apps and focused on smooth UX and predictable UI interactions.

The project demonstrates how to build a custom player interface in UIKit, fully integrated with a Tab Bar and driven by gesture-based transitions.

## Overview

The app allows users to search for music tracks, browse results, and control playback using a custom audio player that smoothly transitions between minimized and expanded states.

Special attention is given to gesture handling, layout animations, and clean architectural separation to keep the UI behavior reliable and easy to extend.

## Core Functionality

- Music search using the iTunes Search API  
- Track playback with AVFoundation  
- Swipe up to expand the audio player from a mini state  
- Swipe down to collapse the player back to the mini view 
- Correct integration with Tab Bar (no layout glitches or background artifacts)  
- Track artwork loading and caching using Kingfisher  
- Predictable, state-driven UI behavior  

## Architecture

- VIP (View–Interactor–Presenter) architecture  
- Clear separation of responsibilities between layers  
- UIKit-based UI with SnapKit for layout constraints  
- Gesture-driven UI transitions powered by constraint animations  
- Reusable and testable business logic  

## Tech Stack

- Swift  
- UIKit  
- SnapKit  
- AVFoundation  
- iTunes Search API  
- Kingfisher  
- VIP Architecture  

## Notes

This project is based on a free, outdated Swiftbook video course.  
The original implementation was independently refactored and rewritten using a modern iOS stack, replacing legacy code and improving architecture, UI behavior, and overall code quality.
