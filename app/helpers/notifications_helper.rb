module NotificationsHelper
  NOTIFICATION_MESSAGES = {
    "liked"          => "أعجب بمقالك",
    "commented"      => "علّق على مقالك",
    "featured"       => "تم تمييز مقالك",
    "picked"         => "تم اختيار مقالك",
    "followed"       => "بدأ متابعتك",
    "replied"        => "ردّ على تعليقك",
    "comment_liked"  => "أعجب بتعليقك"
  }.freeze

  def notification_message(notification)
    NOTIFICATION_MESSAGES[notification.action]
  end

  def notification_path_for(notification)
    case notification.notifiable_type
    when "ArticleLike", "Comment"
      article = notification.notifiable&.article
      user_article_path(slug: article.user, uuid: article) if article
    when "CommentLike"
      article = notification.notifiable&.comment&.article
      user_article_path(slug: article.user, uuid: article) if article
    when "Article"
      article = notification.notifiable
      user_article_path(slug: article.user, uuid: article) if article
    when "Follow"
      user_path(slug: notification.actor)
    end
  end

  def notification_article(notification)
    case notification.notifiable_type
    when "ArticleLike", "Comment"
      notification.notifiable&.article
    when "CommentLike"
      notification.notifiable&.comment&.article
    when "Article"
      notification.notifiable
    when "Follow"
      nil
    end
  end

  def notification_comment(notification)
    case notification.notifiable_type
    when "Comment"
      notification.notifiable
    when "CommentLike"
      notification.notifiable&.comment
    end
  end

  def notification_action_icon(notification)
    case notification.action
    when "liked", "comment_liked"
      tag.span(class: "flex h-5 w-5 items-center justify-center rounded-full bg-red-50 ring-2 ring-white") do
        tag.svg(class: "h-3 w-3 text-red-500", viewBox: "0 0 24 24", fill: "currentColor") do
          tag.path(d: "M11.645 20.91l-.007-.003-.022-.012a15.247 15.247 0 01-.383-.218 25.18 25.18 0 01-4.244-3.17C4.688 15.36 2.25 12.174 2.25 8.25 2.25 5.322 4.714 3 7.688 3A5.5 5.5 0 0112 5.052 5.5 5.5 0 0116.313 3c2.973 0 5.437 2.322 5.437 5.25 0 3.925-2.438 7.111-4.739 9.256a25.175 25.175 0 01-4.244 3.17 15.247 15.247 0 01-.383.219l-.022.012-.007.004-.003.001a.752.752 0 01-.704 0l-.003-.001z")
        end
      end
    when "commented", "replied"
      tag.span(class: "flex h-5 w-5 items-center justify-center rounded-full bg-blue-50 ring-2 ring-white") do
        tag.svg(class: "h-3 w-3 text-blue-500", viewBox: "0 0 24 24", fill: "currentColor") do
          tag.path(fill_rule: "evenodd",
                   d: "M4.848 2.771A49.144 49.144 0 0112 2.25c2.43 0 4.817.178 7.152.52 1.978.292 3.348 2.024 3.348 3.97v6.02c0 1.946-1.37 3.678-3.348 3.97a48.901 48.901 0 01-3.476.383.39.39 0 00-.297.17l-2.755 4.133a.75.75 0 01-1.248 0l-2.755-4.133a.39.39 0 00-.297-.17 48.9 48.9 0 01-3.476-.384c-1.978-.29-3.348-2.024-3.348-3.97V6.741c0-1.946 1.37-3.68 3.348-3.97z",
                   clip_rule: "evenodd")
        end
      end
    when "featured"
      tag.span(class: "flex h-5 w-5 items-center justify-center rounded-full bg-amber-50 ring-2 ring-white") do
        tag.svg(class: "h-3 w-3 text-amber-500", viewBox: "0 0 24 24", fill: "currentColor") do
          tag.path(fill_rule: "evenodd",
                   d: "M10.788 3.21c.448-1.077 1.976-1.077 2.424 0l2.082 5.006 5.404.434c1.164.093 1.636 1.545.749 2.305l-4.117 3.527 1.257 5.273c.271 1.136-.964 2.033-1.96 1.425L12 18.354 7.373 21.18c-.996.608-2.231-.29-1.96-1.425l1.257-5.273-4.117-3.527c-.887-.76-.415-2.212.749-2.305l5.404-.434 2.082-5.005z",
                   clip_rule: "evenodd")
        end
      end
    when "picked"
      tag.span(class: "flex h-5 w-5 items-center justify-center rounded-full bg-emerald-50 ring-2 ring-white") do
        tag.svg(class: "h-3 w-3 text-emerald-500", viewBox: "0 0 24 24", fill: "currentColor") do
          tag.path(fill_rule: "evenodd",
                   d: "M8.603 3.799A4.49 4.49 0 0112 2.25c1.357 0 2.573.6 3.397 1.549a4.49 4.49 0 013.498 1.307 4.491 4.491 0 011.307 3.497A4.49 4.49 0 0121.75 12a4.49 4.49 0 01-1.549 3.397 4.491 4.491 0 01-1.307 3.497 4.491 4.491 0 01-3.497 1.307A4.49 4.49 0 0112 21.75a4.49 4.49 0 01-3.397-1.549 4.49 4.49 0 01-3.498-1.306 4.491 4.491 0 01-1.307-3.498A4.49 4.49 0 012.25 12c0-1.357.6-2.573 1.549-3.397a4.49 4.49 0 011.307-3.497 4.49 4.49 0 013.497-1.307zm7.007 6.387a.75.75 0 10-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 00-1.06 1.06l2.25 2.25a.75.75 0 001.14-.094l3.75-5.25z",
                   clip_rule: "evenodd")
        end
      end
    when "followed"
      tag.span(class: "flex h-5 w-5 items-center justify-center rounded-full bg-purple-50 ring-2 ring-white") do
        tag.svg(class: "h-3 w-3 text-purple-500", viewBox: "0 0 24 24", fill: "currentColor") do
          tag.path(d: "M5.25 6.375a4.125 4.125 0 118.25 0 4.125 4.125 0 01-8.25 0zM2.25 19.125a7.125 7.125 0 0114.25 0v.003l-.001.119a.75.75 0 01-.363.63 13.067 13.067 0 01-6.761 1.873c-2.472 0-4.786-.684-6.76-1.873a.75.75 0 01-.364-.63l-.001-.122zM18.75 7.5a.75.75 0 00-1.5 0v2.25H15a.75.75 0 000 1.5h2.25v2.25a.75.75 0 001.5 0v-2.25H21a.75.75 0 000-1.5h-2.25V7.5z")
        end
      end
    end
  end
end
