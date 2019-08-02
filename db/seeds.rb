# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#テスト用仮データ置き場
#rake db:seedし直すとdelete_allはかかるものの通しidはリセットされないので注意

#User.delete_all
#User.create(name: 'Asan', hobby1: '映画鑑賞', hobby2: 'ドラゴンクエスト', hobby3: 'アイドル')
#User.create(name: 'Bkun', hobby1: '音楽', hobby2: 'アイドル', hobby3: '野球観戦')
#User.create(name: 'Csan', hobby1: 'サイクリング', hobby2: 'プラモ', hobby3: 'まどマギ')
#User.create(name: 'Dsan', hobby1: '酒', hobby2: 'パチスロ', hobby3: 'サイクリング')
#User.create(name: 'Esan', hobby1: 'アイドル', hobby2: 'パチスロ', hobby3: '野球観戦')
#User.create(name: 'Fsan', hobby1: 'アイドル', hobby2: 'ドラゴンクエスト', hobby3: 'プラモ')


User.create(name: 'Asann')
User.create(name: 'Bsann')
User.create(name: 'Csann')
User.create(name: 'Dsann')
User.create(name: 'Esann')
User.create(name: 'Fsann')
User.create(name: 'Gsann')
User.create(name: 'Hsann')
User.create(name: 'Isann')
User.create(name: 'Jsann')
User.create(name: 'Ksann')
User.create(name: 'Lsann')
User.create(name: 'Msann')
User.create(name: 'Nsann')
User.create(name: 'Osann')
User.create(name: 'Psann')
User.create(name: 'Qsann')
User.create(name: 'Rsann')

Group.create(group_name: 'うめぼし')
Group.create(group_name: 'しゃけ')
Group.create(group_name: 'こんぶ')
Group.create(group_name: 'めんたいこ')
Group.create(group_name: 'からし')

Hobby.create(hobby_name: '漫画')
Hobby.create(hobby_name: 'アニメ')
Hobby.create(hobby_name: '惰眠')
Hobby.create(hobby_name: 'ツイ廃')
Hobby.create(hobby_name: '徘徊')
Hobby.create(hobby_name: 'パチスロ')
Hobby.create(hobby_name: '競馬')
Hobby.create(hobby_name: 'ドラクエ')
Hobby.create(hobby_name: 'アイドル')
Hobby.create(hobby_name: 'グラボ')
