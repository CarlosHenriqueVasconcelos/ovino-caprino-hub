import { PushNotifications } from '@capacitor/push-notifications';
import { LocalNotifications } from '@capacitor/local-notifications';
import { Haptics, ImpactStyle } from '@capacitor/haptics';
import { Capacitor } from '@capacitor/core';

export class CapacitorService {
  static async initializeNotifications() {
    if (!Capacitor.isNativePlatform()) {
      console.log('Running on web - using browser notifications');
      return;
    }

    try {
      // Request permission for push notifications
      await PushNotifications.requestPermissions();
      await LocalNotifications.requestPermissions();

      // Register with Apple / Google to receive push via APNS/FCM
      await PushNotifications.register();

      // Show us the notification payload if the app is open on our device
      PushNotifications.addListener('pushNotificationReceived', (notification) => {
        console.log('Push notification received: ', notification);
        this.showLocalNotification(
          notification.title || 'BEGO Agritech',
          notification.body || 'Nova notificação'
        );
      });

      // Method called when tapping on a notification
      PushNotifications.addListener('pushNotificationActionPerformed', (notification) => {
        console.log('Push notification action performed', notification.actionId, notification.inputValue);
      });

      console.log('Capacitor notifications initialized successfully');
    } catch (error) {
      console.error('Error initializing notifications:', error);
    }
  }

  static async showLocalNotification(title: string, body: string, id?: number) {
    try {
      await LocalNotifications.schedule({
        notifications: [{
          id: id || Date.now(),
          title,
          body,
          largeBody: body,
          summaryText: 'BEGO Agritech',
          smallIcon: 'ic_stat_icon_config_sample',
          iconColor: '#8fbc8f',
          actionTypeId: '',
          group: 'bego-notifications',
          schedule: { at: new Date(Date.now() + 1000) }, // Show in 1 second
          sound: 'beep.wav',
          attachments: [],
          extra: {}
        }]
      });

      // Add haptic feedback on native platforms
      if (Capacitor.isNativePlatform()) {
        await Haptics.impact({ style: ImpactStyle.Light });
      }
    } catch (error) {
      console.error('Error showing local notification:', error);
    }
  }

  static async scheduleVaccinationReminder(animalName: string, vaccineName: string, date: Date) {
    try {
      await LocalNotifications.schedule({
        notifications: [{
          id: Date.now(),
          title: '🐑 Vacinação Agendada',
          body: `${animalName} - ${vaccineName}`,
          largeBody: `Lembrete: ${animalName} precisa tomar a vacina ${vaccineName} hoje.`,
          summaryText: 'BEGO Agritech - Vacinação',
          smallIcon: 'ic_stat_icon_config_sample',
          iconColor: '#dc2626',
          actionTypeId: 'vaccination',
          group: 'vaccination-reminders',
          schedule: { at: date },
          sound: 'beep.wav',
          attachments: [],
          extra: {
            type: 'vaccination',
            animalName,
            vaccineName
          }
        }]
      });
    } catch (error) {
      console.error('Error scheduling vaccination reminder:', error);
    }
  }

  static async scheduleBirthReminder(animalName: string, expectedDate: Date) {
    try {
      // Schedule 3 days before expected birth
      const reminderDate = new Date(expectedDate);
      reminderDate.setDate(reminderDate.getDate() - 3);

      await LocalNotifications.schedule({
        notifications: [{
          id: Date.now(),
          title: '🍼 Parto Próximo',
          body: `${animalName} - Previsão em 3 dias`,
          largeBody: `Atenção: ${animalName} tem previsão de parto em 3 dias. Prepare o local adequado.`,
          summaryText: 'BEGO Agritech - Reprodução',
          smallIcon: 'ic_stat_icon_config_sample',
          iconColor: '#ec4899',
          actionTypeId: 'birth',
          group: 'birth-reminders',
          schedule: { at: reminderDate },
          sound: 'beep.wav',
          attachments: [],
          extra: {
            type: 'birth',
            animalName,
            expectedDate: expectedDate.toISOString()
          }
        }]
      });
    } catch (error) {
      console.error('Error scheduling birth reminder:', error);
    }
  }

  static async cancelNotification(id: number) {
    try {
      await LocalNotifications.cancel({
        notifications: [{ id }]
      });
    } catch (error) {
      console.error('Error canceling notification:', error);
    }
  }

  static async getAllScheduledNotifications() {
    try {
      const result = await LocalNotifications.getPending();
      return result.notifications;
    } catch (error) {
      console.error('Error getting scheduled notifications:', error);
      return [];
    }
  }

  static async vibrateDevice() {
    if (Capacitor.isNativePlatform()) {
      try {
        await Haptics.impact({ style: ImpactStyle.Medium });
      } catch (error) {
        console.error('Error vibrating device:', error);
      }
    }
  }
}