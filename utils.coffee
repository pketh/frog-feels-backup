self = 
  
  palettes: [
    ['gold', 'Magenta', 'OrangeRed', 'LimeGreen']
    ['Orchid', 'Teal', 'Olive', 'Blue']
    ['BlueViolet', 'DarkOrange', 'DarkRed', 'LightSkyBlue']
    ['Cyan', 'SaddleBrown', 'LightPink', 'GoldenRod']
  ]
  
  emailHeaders: [
    'https://cdn.hyperdev.com/us-east-1%3A71bc4e4c-4845-48d7-ba7a-4171a4177b55%2Femail-header1.png'
    'https://cdn.hyperdev.com/us-east-1%3A71bc4e4c-4845-48d7-ba7a-4171a4177b55%2Femail-header2.png'
    'https://cdn.hyperdev.com/us-east-1%3A71bc4e4c-4845-48d7-ba7a-4171a4177b55%2Femail-header3.png'
    'https://cdn.hyperdev.com/us-east-1%3A71bc4e4c-4845-48d7-ba7a-4171a4177b55%2Femail-header4.png'
    'https://cdn.hyperdev.com/us-east-1%3A71bc4e4c-4845-48d7-ba7a-4171a4177b55%2Femail-header5.png'
    'https://cdn.hyperdev.com/us-east-1%3A71bc4e4c-4845-48d7-ba7a-4171a4177b55%2Femail-header6.png'
    'https://cdn.hyperdev.com/us-east-1%3A71bc4e4c-4845-48d7-ba7a-4171a4177b55%2Femail-header7.png'
    'https://cdn.hyperdev.com/us-east-1%3A71bc4e4c-4845-48d7-ba7a-4171a4177b55%2Femail-header8.png'
  ]

  # awardKaomoji: [
  #   '八(＾□＾*)'
  #   '~ヾ(＾∇＾)'
  #   '(ノ*゜▽゜*)'
  #   '(ノ^o^)ノ'
  #   'ヽ(°◇° )ノ'
  # ]

  artMedium: [
    "airbrush"
    "acrylic"
    "chalk"
    "charcoal"
    "gouache"
    "ink"
    "oil"
    "pastel"
    "watercolor"
    "sand"
  ]
  
  artSurface: [
    "canvas"
    "stir fry"
    "plaster"
    "vellum"
    "film"
    "ex's car"
    "home depot parking lot"
    "neighbor's lawn"
    "eldritch vision"
  ]

  capitalizeFirstLetter: (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)

module.exports = self
