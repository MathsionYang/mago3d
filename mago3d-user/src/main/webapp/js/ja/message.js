var JS_MESSAGE = new Object();

JS_MESSAGE["create"] = "作成されました。";
JS_MESSAGE["insert"] = "登録されました。";
JS_MESSAGE["update"] = "修正されました。";
JS_MESSAGE["delete"] = "削除されました。";
JS_MESSAGE["success"] = "成功しました。";
JS_MESSAGE["apply"] = "適用されました。";
JS_MESSAGE["upload"] = "アップロード中です。";
JS_MESSAGE["move.confirm"] = "移動しますか？";
JS_MESSAGE["delete.confirm"] = "削除しますか？";
JS_MESSAGE["check.value.required"] = "選択された項目がありません。";

//共通
JS_MESSAGE["user.session.empty"] = "ログイン後に使用可能なサービスです。";
JS_MESSAGE["db.exception"] = "データベースに障害が発生しました。しばらくしてから再度ご利用ください。";
JS_MESSAGE["ajax.error.message"] = "しばらくしてご利用下さい。長時間同じ現象が繰り返される場合は、管理者に問い合わせてください。";
JS_MESSAGE["button.dobule.click"] = "進行中です。";
JS_MESSAGE["cache.reloaded"] = "キャッシュを更新しました。";
JS_MESSAGE["usersession.grant.invalid"] = "アクセス許可が有効ではありません。";

JS_MESSAGE["login.password.decrypt.exception"] = "ログインパスワード処理中にエラーが発生しました。";

//ユーザー
JS_MESSAGE["user.id.empty"] = "ユーザ名を入力してください。";
JS_MESSAGE["user.id.min_length.invalid"] = "ユーザー名が短すぎます。";
JS_MESSAGE["password.empty"] = "パスワードを入力してください。";
JS_MESSAGE["password.correct.empty"] = "パスワードの確認を入力してください。";
JS_MESSAGE["user.name.empty"] = "名前を入力してください。";
JS_MESSAGE["user.input.invalid"] = "必須入力値が有効ではありません。";
JS_MESSAGE["user.id.duplication"] = "使用中のIDです。他のIDを選択してください。";
JS_MESSAGE["user.password.invalid"] = "入力したパスワードが設定されたパスワードポリシーに不適合です。";
JS_MESSAGE["user.password.digit.invalid"] = "入力したパスワードが設定されたパスワードポリシーの（数字の数）に不適合です。";
JS_MESSAGE["user.password.upper.invalid"] = "入力したパスワードが設定されたパスワードポリシーの（英語の大文字数）に不適合です。";
JS_MESSAGE["user.password.lower.invalid"] = "入力したパスワードが設定されたパスワードポリシーの（英語の小文字数）に不適合です。";
JS_MESSAGE["user.password.special.invalid"] = "入力したパスワードが設定されたパスワードポリシーの（特殊文字の数）に不適合です。";
JS_MESSAGE["user.password.continuous.char.invalid"] = "継続文字制限数がパスワードポリシーに不適合です。";
JS_MESSAGE["user.password.exception.char.message1"] = "管理者が設定した特殊文字";
JS_MESSAGE["user.password.exception.char.message2"] = "は、パスワードとして使用することができません。";
JS_MESSAGE["user.password.exception"] = "パスワードの登録処理中にエラーが発生しました。";
JS_MESSAGE["user.session.notexist"] = "セッション情報が存在しません。";
JS_MESSAGE["user.session.closed"] = "セッション終了処理しました。";
JS_MESSAGE["user.session.close"] = "選択したユーザーのセッションを終了しますか？";
JS_MESSAGE["user.id.enable"] = "使用可能なIDです。";
JS_MESSAGE["user.insert"] = "ユーザーを登録しました。";
JS_MESSAGE["user.info.update"] = "ユーザー情報を修正しました。";
JS_MESSAGE["user.id.notexist"] = "ユーザ名が存在しません。";


//運営ポリシー
JS_MESSAGE["policy.server.datetime"] = "サーバーの時間がリセットされました。"
JS_MESSAGE["policy.user.update"] = "ユーザーポリシーを変更しました。";
JS_MESSAGE["policy.password.update"] = "パスワードポリシーを変更しました。";
JS_MESSAGE["policy.geo.update"] = "空間情報を修正しました。";
JS_MESSAGE["policy.geoserver.update"] = "GeoServerを修正しました。";
JS_MESSAGE["policy.geocallback.update"] = "CallBack関数を修正しました。";
JS_MESSAGE["policy.notice.update"] = "通知ポリシーを修正しました。";
JS_MESSAGE["policy.security.update"] = "セキュリティポリシーを変更しました。";
JS_MESSAGE["policy.content.update"] = "コンテンツポリシーを変更しました。";
JS_MESSAGE["policy.site.update"] = "サイトの情報を修正しました。";
JS_MESSAGE["policy.os.update"] = "OSの設定情報を変更しました。";
JS_MESSAGE["policy.backoffice.update"] = "Back Officeの情報を修正しました。";
JS_MESSAGE["policy.solution.update"] = "製品情報を修正しました。";
JS_MESSAGE["policy.content.invalid"] = "必須入力値が有効ではありません。";

//データ
JS_MESSAGE["data.key.empty"] = "Keyを入力してください。";
JS_MESSAGE["data.key.duplication_value.check"] = "Key重複確認をしてください。"
JS_MESSAGE["data.key.duplication_value.already"] = "使用中のKeyです。他のKeyを選択してください。";
JS_MESSAGE["data.project.id.empty"] = "プロジェクトを選択してください。";
JS_MESSAGE["data.latitude.empty"] = "緯度を入力してください。";
JS_MESSAGE["data.longitude.empty"] = "経度を入力してください。";
JS_MESSAGE["data.height.empty"] = "高さを入力してください。";
JS_MESSAGE["data.heading.empty"] = "Headingを入力してください。";
JS_MESSAGE["data.pitch.empty"] = "Pitchを入力してください。";
JS_MESSAGE["data.roll.empty"] = "Rollを入力してください。";
JS_MESSAGE["data.key.duplication"] = "使用中のIDです。他のIDを選択してください。";
JS_MESSAGE["data.key.enable"] = "使用可能なKeyです。";
JS_MESSAGE["data.insert"] = "データを登録しました。";
JS_MESSAGE["user.info.update"] = "ユーザー情報を修正しました。";

//問題
JS_MESSAGE["issue.project.id.empty"] = "プロジェクトを選択してください。";
JS_MESSAGE["issue.issuetype.empty"] = "issueタイプを選択してください。";
JS_MESSAGE["issue.datakey.empty"] = "日付キーを入力してください。";
JS_MESSAGE["issue.title.empty"] = "タイトルを入力してください。";
JS_MESSAGE["issue.assignee.empty"] = "代理者を入力してください";
JS_MESSAGE["issue.reporter.empty"] = "報告者を入力してください。";
JS_MESSAGE["issue.contents.empty"] = "内容を入力してください。";
JS_MESSAGE["issue.due_day.invalid"] = "issue期限を正しく入力してください。";
JS_MESSAGE["issue.due_time.invalid"] = "issue締切を正しく入力してください。";
