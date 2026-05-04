// Notification system utilities

export interface Notification {
  id: string;
  userId: string;
  userRole?: string;
  moduleName?: string;
  type: "submission_status" | "new_submission" | "approval_request" | "revision_requested" | "system";
  title: string;
  message: string;
  submissionId?: string;
  status?: "pending" | "approved" | "rejected" | "revision_requested";
  read: boolean;
  createdAt: string;
  actionUrl?: string;
}

const NOTIFICATIONS_KEY = "notifications";

// Create notification
export const createNotification = (notification: Omit<Notification, "id" | "createdAt" | "read">): Notification => {
  try {
    const notifications = getAllNotifications();
    const notificationId = `NOTIF-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const newNotification: Notification = {
      ...notification,
      id: notificationId,
      createdAt: new Date().toISOString(),
      read: false,
    };
    
    notifications.push(newNotification);
    localStorage.setItem(NOTIFICATIONS_KEY, JSON.stringify(notifications));
    
    // Trigger browser notification if permission granted
    if ("Notification" in window && Notification.permission === "granted") {
      new Notification(newNotification.title, {
        body: newNotification.message,
        icon: "/arms/ebomi.jpg",
      });
    }
    
    return newNotification;
  } catch (error) {
    console.error("Error creating notification:", error);
    throw error;
  }
};

// Get all notifications
export const getAllNotifications = (userId?: string, unreadOnly?: boolean): Notification[] => {
  try {
    const notificationsStr = localStorage.getItem(NOTIFICATIONS_KEY);
    if (!notificationsStr) return [];
    
    let notifications = JSON.parse(notificationsStr) as Notification[];
    
    if (userId) {
      notifications = notifications.filter(n => n.userId === userId);
    }
    
    if (unreadOnly) {
      notifications = notifications.filter(n => !n.read);
    }
    
    return notifications.sort((a, b) => 
      new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );
  } catch (error) {
    console.error("Error loading notifications:", error);
    return [];
  }
};

// Mark notification as read
export const markAsRead = (notificationId: string): boolean => {
  try {
    const notifications = getAllNotifications();
    const index = notifications.findIndex(n => n.id === notificationId);
    
    if (index === -1) return false;
    
    notifications[index].read = true;
    localStorage.setItem(NOTIFICATIONS_KEY, JSON.stringify(notifications));
    return true;
  } catch (error) {
    console.error("Error marking notification as read:", error);
    return false;
  }
};

// Mark all as read
export const markAllAsRead = (userId?: string): boolean => {
  try {
    const notifications = getAllNotifications();
    
    notifications.forEach(notification => {
      if (!userId || notification.userId === userId) {
        notification.read = true;
      }
    });
    
    localStorage.setItem(NOTIFICATIONS_KEY, JSON.stringify(notifications));
    return true;
  } catch (error) {
    console.error("Error marking all as read:", error);
    return false;
  }
};

// Delete notification
export const deleteNotification = (notificationId: string): boolean => {
  try {
    const notifications = getAllNotifications();
    const filtered = notifications.filter(n => n.id !== notificationId);
    localStorage.setItem(NOTIFICATIONS_KEY, JSON.stringify(filtered));
    return true;
  } catch (error) {
    console.error("Error deleting notification:", error);
    return false;
  }
};

// Get unread count
export const getUnreadCount = (userId?: string): number => {
  const notifications = getAllNotifications(userId, true);
  return notifications.length;
};

// Request notification permission
export const requestNotificationPermission = async (): Promise<boolean> => {
  if (!("Notification" in window)) {
    console.log("This browser does not support notifications");
    return false;
  }
  
  if (Notification.permission === "granted") {
    return true;
  }
  
  if (Notification.permission !== "denied") {
    const permission = await Notification.requestPermission();
    return permission === "granted";
  }
  
  return false;
};
