$pp = 0.7
$hpp = 0.5*$pp
$qpp = 0.5*$hpp
$opp = 0.5*$qpp
$xpp = 0.5*$opp

bell_samples = (ring [:elec_triangle,1,0.5])
bell_sleeps = (ring $pp*2)

bass_samples = (ring [:bd_pure,2],[:bd_pure,1.5],
                [:bd_pure,2],[:bd_pure,1.5],
                [:bd_pure,2],[:bd_pure,1.5],
                [:bd_pure,2],[:bd_pure,1.5],[:bd_pure,1.5])
bass_sleeps = (ring $pp,$pp,$pp,$pp,$pp,$pp,$pp,$hpp,$hpp)

drum_roll = (ring [:drum_roll, 1, 0.5])
drum_roll_sleeps = (ring $pp)
pl1 = (ring :e3,:e3,:f3,:g3,:g3,:f3,:e3,:d3,:c3,:c3,:d3,:e3,:e3,:d3,:d3,
       :e3,:e3,:f3,:g3,:g3,:f3,:e3,:d3,:c3,:c3,:d3,:e3,:d3,:c3,:c3).map {|pp| pp+14}
sl1 = (ring $hpp,$hpp,$hpp,$hpp,$hpp,$hpp,$hpp,
       $hpp,$hpp,$hpp,$hpp,$hpp,$pp-$qpp,$qpp,$pp)

define :main_play do |n, rel, play_amp=1|
  play n,amp: play_amp,release: rel
end
define :play_part do |notes, sleeps|
  loop do
    sleep_tick = sleeps.tick(:slt)
    note_tick = notes.tick(:nt)
    main_play note_tick, sleep_tick
    sleep sleep_tick
    if look(:nt) == notes.length-1 then
      tick_reset_all
      break
    end
  end
end

define :sample_part do |samples, sleeps, dur=1|
  loop do
    sleep_tick = sleeps.tick(:sst)
    sample_tick = samples.tick(:spt)
    sample_amp = 1
    if sample_tick.length > 2 then sample_amp = sample_tick[2] end
    sample sample_tick[0], rate: sample_tick[1], sustain: sample_duration(sample_tick[0])*dur,amp: sample_amp
    sleep sleep_tick
    if look(:spt) == samples.length-1 then
      tick_reset_all
      break
    end
  end
end

with_fx :hpf, mix: 0.2,cutoff: 80 do
  live_loop:mian do
    use_synth :hollow
    play_part(pl1, sl1)
  end
end

live_loop :bass do
  sample_part(bass_samples,bass_sleeps,0.5)
end

live_loop :bell do
  sample_part(bell_samples,bell_sleeps,1)
end