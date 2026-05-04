"use client";

import { useState, useEffect } from "react";
import { Bell, Check, X } from "lucide-react";
import { getAllNotifications, markAsRead, markAllAsRead, deleteNotification, getUnreadCount } from "@/lib/notifications";
import { Notification } from "@/lib/notifications";
import { useRouter } from "next/navigation";

interface NotificationBellProps {
  userId: string;
}

export default function NotificationBell({ userId }: NotificationBellProps) {
  const router = useRouter();
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    loadNotifications();
    const interval = setInterval(loadNotifications, 10000); // Refresh every 10 seconds
    return () => clearInterval(interval);
  }, [userId]);

  const loadNotifications = () => {
    const all = getAllNotifications(userId);
    const unread = getUnreadCount(userId);
    setNotifications(all);
    setUnreadCount(unread);
  };

  const handleNotificationClick = (notification: Notification) => {
    if (!notification.read) {
      markAsRead(notification.id);
      loadNotifications();
    }
    
    if (notification.actionUrl) {
      router.push(notification.actionUrl);
      setIsOpen(false);
    }
  };

  const handleMarkAllRead = () => {
    markAllAsRead(userId);
    loadNotifications();
  };

  const handleDelete = (e: React.MouseEvent, notificationId: string) => {
    e.stopPropagation();
    deleteNotification(notificationId);
    loadNotifications();
  };

  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return "Just now";
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return date.toLocaleDateString();
  };

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative p-2 text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors"
      >
        <Bell size={20} />
        {unreadCount > 0 && (
          <span className="absolute top-0 right-0 w-5 h-5 bg-red-500 text-white text-xs rounded-full flex items-center justify-center">
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        )}
      </button>

      {isOpen && (
        <>
          <div
            className="fixed inset-0 z-10"
            onClick={() => setIsOpen(false)}
          />
          <div className="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-lg border border-gray-200 z-20 max-h-96 overflow-hidden flex flex-col">
            <div className="p-4 border-b border-gray-200 flex items-center justify-between">
              <h3 className="font-semibold text-gray-800">Notifications</h3>
              {unreadCount > 0 && (
                <button
                  onClick={handleMarkAllRead}
                  className="text-xs text-primary-600 hover:text-primary-700"
                >
                  Mark all read
                </button>
              )}
            </div>

            <div className="overflow-y-auto flex-1">
              {notifications.length === 0 ? (
                <div className="p-8 text-center text-gray-500 text-sm">
                  No notifications
                </div>
              ) : (
                <div className="divide-y divide-gray-100">
                  {notifications.map((notification) => (
                    <div
                      key={notification.id}
                      onClick={() => handleNotificationClick(notification)}
                      className={`p-4 hover:bg-gray-50 cursor-pointer transition-colors ${
                        !notification.read ? "bg-blue-50" : ""
                      }`}
                    >
                      <div className="flex items-start justify-between gap-2">
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <p className={`font-medium text-sm ${!notification.read ? "text-gray-900" : "text-gray-700"}`}>
                              {notification.title}
                            </p>
                            {!notification.read && (
                              <span className="w-2 h-2 bg-primary-600 rounded-full flex-shrink-0" />
                            )}
                          </div>
                          <p className="text-xs text-gray-600 line-clamp-2">
                            {notification.message}
                          </p>
                          <p className="text-xs text-gray-500 mt-1">
                            {formatTime(notification.createdAt)}
                          </p>
                        </div>
                        <button
                          onClick={(e) => handleDelete(e, notification.id)}
                          className="p-1 hover:bg-gray-200 rounded text-gray-400 hover:text-gray-600 transition-colors flex-shrink-0"
                        >
                          <X size={14} />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </>
      )}
    </div>
  );
}


