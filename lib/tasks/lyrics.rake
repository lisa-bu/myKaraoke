namespace :lyrics do
  desc "Populate hardcoded lyrics for demo songs"
  task seed: :environment do
    demo_lyrics = {
      ["...Baby One More Time", "Britney Spears"] => <<~LYRICS,
        [Intro]
        Oh, baby, baby
        Oh, baby, baby

        [Verse 1]
        Oh, baby, baby
        How was I supposed to know
        That somethin' wasn't right here?
        Oh, baby, baby
        I shouldn't have let you go
        And now you're out of sight, yeah

        [Pre-Chorus]
        Show me how you want it to be
        Tell me, baby, 'cause I need to know now
        Oh, because

        [Chorus]
        My loneliness is killin' me (And I)
        I must confess, I still believe (Still believe)
        When I'm not with you, I lose my mind
        Give me a sign
        Hit me, baby, one more time

        [Verse 2]
        Oh, baby, baby
        The reason I breathe is you (Oh yeah)
        Boy, you got me blinded
        Oh, pretty baby
        There's nothing that I wouldn't do
        It's not the way I planned it

        [Pre-Chorus]
        Show me how you want it to be
        Tell me, baby, 'cause I need to know now
        Oh, because

        [Chorus]
        My loneliness is killin' me (And I)
        I must confess, I still believe (Still believe)
        When I'm not with you, I lose my mind
        Give me a sign
        Hit me, baby, one more time

        [Post-Chorus]
        Oh, baby, baby (Oh)
        Oh, baby, baby (Yeah, yeah)

        [Bridge]
        Oh, baby, baby
        How was I supposed to know?
        Oh, pretty baby
        I shouldn't have let you go
        I must confess that my loneliness is killin' me now
        Don't you know I still believe
        That you will be here and give me a sign?
        Hit me, baby, one more time

        [Chorus]
        My loneliness is killin' me (And I)
        I must confess, I still believe (Still believe)
        When I'm not with you, I lose my mind
        Give me a sign
        Hit me, baby, one more time

        [Outro]
        I must confess that my loneliness (My loneliness is killin' me)
        Is killin' me now (I must confess, I still believe)
        Don't you know I still believe (When I'm not with you, I lose my mind)
        That you will be here and give me a sign?
        Hit me, baby, one more time
      LYRICS

      ["Believe", "Cher"] => <<~LYRICS,
        [Intro]
        (After love, after love)
        (After love, after love)
        (After love, after love)
        (After love, after love)
        (After love, after love)
        (After love, after love)

        [Verse 1]
        No matter how hard I try
        You keep pushing me aside
        And I can't break through
        There's no talking to you
        It's so sad that you're leaving
        It takes time to believe it
        But after all is said and done
        You're gonna be the lonely one, oh

        [Chorus]
        Do you believe in life after love?
        I can feel something inside me say
        "I really don't think you're strong enough, no"
        Do you believe in life after love?
        I can feel something inside me say
        "I really don't think you're strong enough, no"

        [Verse 2]
        What am I supposed to do
        Sit around and wait for you?
        Well, I can't do that
        And there's no turning back
        I need time to move on
        I need love to feel strong
        'Cause I've had time to think it through
        And maybe I'm too good for you, oh

        [Chorus]
        Do you believe in life after love?
        I can feel something inside me say
        "I really don't think you're strong enough, no"
        Do you believe in life after love?
        I can feel something inside me say
        "I really don't think you're strong enough, no"

        [Bridge]
        Well, I know that I'll get through this
        'Cause I know that I am strong
        And I don't need you anymore
        Oh, I don't need you anymore
        Oh, I don't need you anymore
        No, I don't need you anymore

        [Chorus]
        Do you believe in life after love?
        I can feel something inside me say
        "I really don't think you're strong enough, no"
        Do you believe in life after love?
        I can feel something inside me say
        "I really don't think you're strong enough, no"
        Do you believe in life after love?
        I can feel something inside me say
        "I really don't think you're strong enough, no"
        Do you believe in life after love?
        I can feel something inside me say
        "I really don't think you're strong enough, no"
        (Do you believe in life after love?)
      LYRICS

      ["American Girl", "Tom Petty and the Heartbreakers"] => <<~LYRICS,
        [Verse 1]
        Well, she was an American girl
        Raised on promises
        She couldn't help thinkin' that there
        Was a little more to life somewhere else
        After all, it was a great big world
        With lots of places to run to
        And if she had to die tryin', she
        Had one little promise she was gonna keep

        [Chorus]
        Oh yeah, all right
        Take it easy, baby
        Make it last all night (Make it last all night)
        She was an American girl

        [Verse 2]
        Well, it was kinda cold that night
        She stood alone on her balcony (Ooh)
        Yeah, she could hear the cars roll by
        Out on 441 like waves crashin' on the beach
        And for one desperate moment there
        He crept back in her memory
        God, it's so painful when something that is so close
        Is still so far out of reach

        [Chorus]
        Oh yeah, all right
        Take it easy, baby
        Make it last all night (Make it last all night)
        She was an American girl (Ooh)
      LYRICS

      ["Toxic", "Britney Spears"] => <<~LYRICS
        [Verse 1]
        Baby, can't you see I'm callin'?
        A guy like you should wear a warnin'
        It's dangerous, I'm fallin'
        There's no escape, I can't wait
        I need a hit, baby, give me it
        You're dangerous, I'm lovin' it

        [Pre-Chorus]
        Too high, can't come down
        Losing my head, spinnin' 'round and 'round
        Do you feel me now?

        [Chorus]
        With a taste of your lips, I'm on a ride
        You're toxic, I'm slippin' under
        With a taste of a poison paradise
        I'm addicted to you
        Don't you know that you're toxic?
        And I love what you do
        Don't you know that you're toxic?

        [Verse 2]
        It's gettin' late to give you up
        I took a sip from my devil's cup
        Slowly, it's takin' over me

        [Pre-Chorus]
        Too high, can't come down
        It's in the air and it's all around
        Can you feel me now?

        [Chorus]
        With a taste of your lips, I'm on a ride
        You're toxic, I'm slippin' under
        With a taste of a poison paradise
        I'm addicted to you
        Don't you know that you're toxic?
        And I love what you do
        Don't you know that you're toxic?
        Don't you know that you're toxic?

        [Instrumental Break]

        [Chorus]
        Taste of your lips, I'm on a ride
        You're toxic, I'm slippin' under
        With a taste of a poison paradise
        I'm addicted to you
        Don't you know that you're toxic?
        With a taste of your lips, I'm on a ride
        You're toxic, I'm slippin' under (Toxic)
        With a taste of a poison paradise
        I'm addicted to you
        Don't you know that you're toxic?

        [Outro]
        Intoxicate me now with your lovin' now
        I think I'm ready now (I think I'm ready now)
        Intoxicate me now with your lovin' now
        I think I'm ready now
      LYRICS
    }

    updated_count = 0

    demo_lyrics.each do |(title, artist), lyrics|
      # Try exact match first
      song = Song.find_by("LOWER(name) = LOWER(?) AND LOWER(artist) = LOWER(?)", title, artist)

      # Try partial match on name if no exact match
      song ||= Song.find_by("LOWER(name) LIKE LOWER(?) AND LOWER(artist) LIKE LOWER(?)", "%#{title}%", "%#{artist.split.first}%")

      if song
        song.update!(lyrics: lyrics.strip)
        puts "✓ Updated lyrics for: #{song.artist} - #{song.name}"
        updated_count += 1
      else
        puts "✗ Song not found: #{artist} - #{title}"
      end
    end

    puts "\nUpdated #{updated_count} songs with lyrics."
  end
end
