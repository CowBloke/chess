using Godot;
using System;

public partial class SoundManager : AudioStreamPlayer
{

    public enum Sounds
    {
        Move,
        Capture,
        Check,
        Castle
    }

    AudioStreamMP3 move;
    AudioStreamMP3 capture;
    AudioStreamMP3 check;
    AudioStreamMP3 castle;

    public override void _Ready()
	{
        LoadSounds();
    }
    
    public void PlaySound(Sounds sound)
    {
        switch (sound)
        {
            case Sounds.Move:
                Stream = move;
                break;
            case Sounds.Capture:
                Stream = capture;
                break;
            case Sounds.Check:
                Stream = check;
                break;
            case Sounds.Castle:
                Stream = castle;
                break;
        }
        Play();
    }

    public void LoadSounds()
    {
        move = GD.Load<AudioStreamMP3>("res://sounds/move.mp3");
        capture = GD.Load<AudioStreamMP3>("res://sounds/capture.mp3");
        check = GD.Load<AudioStreamMP3>("res://sounds/check.mp3");
        castle = GD.Load<AudioStreamMP3>("res://sounds/castle.mp3");
    }


}
