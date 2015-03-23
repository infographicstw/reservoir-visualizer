angular.module \main, <[]>
  ..controller \main, <[$scope $http]> ++ ($scope, $http) ->
    pad = (v, len=2)->
      u = "#v"
      if u.length < len => return (" " * (len - u.length)) + u
      return u
    liquid-height = do
      side: d3.scale.linear!domain [0 100] .range [260 60]
      bottom: d3.scale.linear!domain [0 100] .range [290 80]
      top:  d3.scale.linear!domain [0 100] .range [230 40]
    color = d3.scale.linear!domain [0 25 50 75 100] .range <[#f03 #f96 #ff9 #9fc #0ff]>
    $http do
      url: \live.json
      method: \GET
    .success (data) ->
      names = [k for k of data]
      dates = [k for k of data[names[0]]]sort!

      x-axis = d3.scale.ordinal!domain dates .range [0 to 765 by 765/dates.length]
      y-axis = d3.scale.linear!domain [0 100] .range [173 7]
      $scope.reservoirs = []
      for n in names
        link = []
        for i from dates.length - 2 to 0 by -1
          d1 = dates[i]
          d2 = dates[i + 1]
          p1 = data[n][d1]p
          p2 = data[n][d2]p
          nodata = if p1 == -1 or p2 == -1 => true else false
          if !nodata => link.push [x-axis(d1), x-axis(d2), y-axis(data[n][d1]p), y-axis(data[n][d2]p)]
        volume = parseInt( data[n][dates[* - 1]]v / 10 ) / 10
        percent = parseInt ( data[n][dates[* - 1]]p * 10 ) / 10

        idx = dates.length - 1
        [p1,p2] = [-1,-1]
        while p1 == -1 => 
          if !data[n][dates[idx]] => break
          p1 = data[n][dates[idx]]p
          idx--
        jdx = idx - 7
        while p2 == -1 =>
          if !data[n][dates[jdx]] => break
          p2 = data[n][dates[jdx]]p
          jdx--
        delta = (p2 - p1) / (idx - jdx + 1)
        if delta > 0 => remains = parseInt(p1 / 7 / delta) else remains = -1


        obj = do
          name: n, 
          side: liquid-height.side data[n][dates[* - 1]]p
          bottom: liquid-height.bottom data[n][dates[* - 1]]p
          top: liquid-height.top data[n][dates[* - 1]]p
          color: color data[n][dates[* - 1]]p
          link: link
          volume: volume
          percent: percent
          start: dates[0]
          end: dates[* - 1]
          remains: remains
        $scope.reservoirs.push obj
