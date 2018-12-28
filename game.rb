$pp = 0.95
$hpp = 0.5*$pp
$qpp = 0.25*$pp

$rele = 0.2

pl1 = (ring 59,62,62,64,66,62,66,59,62,64,64,
       59,62,62,64,66,62,64,59,62,64,62)
sl1 = (ring $qpp,$qpp,$qpp,$qpp,$hpp,
       $qpp,$hpp,$qpp,$qpp,$qpp,$pp)
pl2 = (ring 66,66,59,62,64,68,66,64,59,62,59,
       66,66,59,62,64,68,66,64,59,62,62).map {|e| e+2}
sl2 = (ring $qpp,$qpp,$qpp,$qpp,$hpp,
       $qpp,$qpp,$hpp,$qpp,$qpp,$pp)

drum_samples = (ring [:loop_amen,1,1,0.05,0,0.95])
drum_sleeps = (ring $pp,$qpp*0.5,$qpp*0.5,$qpp,$qpp,$qpp)

bass_samples = (ring [:bd_haus, 1, 0.3])
bass_sleeps = (ring $pp,$pp,$pp+$hpp,$qpp,$qpp,$pp,$pp,$hpp,$hpp,$hpp,$hpp)

$windamp = 0.15
$windrel = 0.5
wind_plays = (ring 54,57,59,59,54,57,59,57)
wind_sleeps = (ring $hpp,$pp+$hpp)

define :main_play do |n|
  play n+$randoff, amp: 0.5,release: $rele
end
define :play_part do |pl, sl, pl_amp=1, pl_rel=$pp|
  loop do
    play pl.tick(:plt),amp: pl_amp,release: pl_rel
    sleep sl.tick(:slt)
    if look(:plt) == pl.length-1 then
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
    sample_release = 0
    sample_attack = 0
    sample_start = 0
    if sample_tick.length > 2 then sample_amp = sample_tick[2] end
    if sample_tick.length > 3 then sample_release = sample_tick[3] end
    if sample_tick.length > 4 then sample_attack = sample_tick[4] end
    if sample_tick.length > 5 then sample_start = sample_tick[5] end
    sample sample_tick[0], rate: sample_tick[1],
      sustain: sample_duration(sample_tick[0])*dur,
      amp: sample_amp,
      release: sample_release,
      start: sample_start
    sleep sleep_tick
    mlength = samples.length
    mtick = look(:spt)
    if samples.length<sleeps.length then
      mlength = sleeps.length
      mtick = look(:sst)
    end
    if mtick == mlength-1 then
      tick_reset_all
      break
    end
  end
end

with_fx :echo, mix: 0.3 do
  live_loop :main do
    use_synth :pluck
    sleep 8*$pp
    2.times do
      play_part pl1, sl1, 0.5, $rele
    end
    2.times do
      play_part pl2, sl2, 0.5, $rele
    end
    2.times do
      play_part pl1, sl1, 0.5, $rele
    end
  end
end

live_loop :bas do
  sample_part(bass_samples, bass_sleeps)
end

live_loop :dru do
  sample :drum_cymbal_closed
  sample_part(drum_samples, drum_sleeps)
end

live_loop :bell do
  sleep $pp
  sample :elec_triangle,amp: 0.5
  sleep $qpp
  sample :elec_triangle,amp: 0.5
  sleep $qpp*3
end

live_loop :wind do
  use_synth :tri
  play_part wind_plays, wind_sleeps, $windamp, $windrel
end
