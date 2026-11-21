#!/bin/bash
# Remaining context, and usage of the 5-hour and weekly rate-limit windows.
jq -r '
  def pct(v): if v == null then "–" else "\(v)%" end;
  def reset(t): if t == null then "" else " (" + (t | strflocaltime("%a %H:%M")) + ")" end;
  "ctx left \(pct(.context_window.remaining_percentage))"
  + " · 5h \(pct(.rate_limits.five_hour.used_percentage))\(reset(.rate_limits.five_hour.resets_at))"
  + " · week \(pct(.rate_limits.seven_day.used_percentage))\(reset(.rate_limits.seven_day.resets_at))"
'
