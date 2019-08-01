# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#テスト用仮データ置き場
#rake db:seedし直すとdelete_allはかかるものの通しidはリセットされないので注意

User.delete_all
User.create(name: 'Asan', hobby1: '映画鑑賞', hobby2: 'ドラゴンクエスト', hobby3: 'アイドル')
User.create(name: 'Bkun', hobby1: '音楽', hobby2: 'アイドル', hobby3: '野球観戦')
User.create(name: 'Csan', hobby1: 'サイクリング', hobby2: 'プラモ', hobby3: 'まどマギ')
User.create(name: 'Dsan', hobby1: '酒', hobby2: 'パチスロ', hobby3: 'サイクリング')
