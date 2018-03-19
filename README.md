# Zany
a flexible class for AVPlayer


# Zany - a music(radio) player  in AVPlayer



### Player

#### Create a player

```swift
  let player = Zany(url: url)
```

#### Create a player with progress.

```swift
  let player = Zany(url: url, observer: { (zany, progress) -> (Void) in
    // DispatchQueue.main
    // update UI about progress

  })
```


#### Manage a player

You can create a new instance of player and play as needed by calling the `play()` function.

```swift
  let player = Zany(url: url, observer: { (zany, progress) -> (Void) in
    // DispatchQueue.main
    // update UI about progress

  })
  player.play()
```

Other functions are:

* `play()`: play a paused or newly created player
* `pause()`: pause a running player
* `reset(_ url: URL?, restart: Bool = true)`: reset a running player, change the URL.

Properties:

* `.id`: unique identifier of the player
* `.state`: define the type of timer (`paused`,`running`,`finished`)


#### Adding/Removing Observers

you can add progress Observers for the Zany instance 


```swift
let token = player.observe { (zany, progress) -> (Void) in
    // DispatchQueue.main
    // update UI about progress
}
player.play()
```

You can remove an observer by using the token:

```swift 
player.remove(observer: token)
```

#### Observing state change
You can listen for state change by assigning a function callback for `.onStateChanged` property.

```swift
 player.onStateChanged = {(zany,newState) in
            
      switch newState {
      case .running:
           //  for example: change button state
           //  the player is running
      case .paused:
           //  the player is paused
                
      case .finished:
           //  the player playFinished
            
       }
 }
```





## Requirements

Zany is compatible with Swift 4.x.
All Apple platforms are supported:

* iOS 9.0+




