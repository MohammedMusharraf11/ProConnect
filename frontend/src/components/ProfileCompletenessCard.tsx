import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import { CheckCircle2, Circle } from 'lucide-react';

interface ProfileCompletenessCardProps {
  completeness: number;
  user: any;
}

const ProfileCompletenessCard = ({ completeness, user }: ProfileCompletenessCardProps) => {
  const items = [
    { label: 'Profile Picture', completed: !!user?.PROFILE_PIC_URL },
    { label: 'Headline', completed: !!user?.HEADLINE },
    { label: 'Bio', completed: !!user?.BIO },
    { label: 'Phone Number', completed: !!user?.PHONE },
    { label: 'Location', completed: !!user?.CITY },
    { label: 'Industry', completed: !!user?.INDUSTRY },
    { label: 'Experience', completed: false }, // Will be checked via API
    { label: 'Education', completed: false },
    { label: 'Skills', completed: false },
    { label: 'Projects', completed: false },
  ];

  const getCompletenessColor = (percentage: number) => {
    if (percentage >= 80) return 'text-green-600';
    if (percentage >= 50) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getCompletenessMessage = (percentage: number) => {
    if (percentage === 100) return 'Your profile is complete! 🎉';
    if (percentage >= 80) return 'Almost there! Keep going.';
    if (percentage >= 50) return 'You\'re halfway there!';
    return 'Let\'s complete your profile!';
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-base">Profile Strength</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className={`text-2xl font-bold ${getCompletenessColor(completeness)}`}>
              {completeness}%
            </span>
            <span className="text-sm text-muted-foreground">
              {getCompletenessMessage(completeness)}
            </span>
          </div>
          <Progress value={completeness} className="h-2" />
        </div>

        <div className="space-y-2">
          {items.slice(0, 6).map((item, index) => (
            <div key={index} className="flex items-center gap-2 text-sm">
              {item.completed ? (
                <CheckCircle2 className="h-4 w-4 text-green-600" />
              ) : (
                <Circle className="h-4 w-4 text-muted-foreground" />
              )}
              <span className={item.completed ? 'text-foreground' : 'text-muted-foreground'}>
                {item.label}
              </span>
            </div>
          ))}
        </div>

        {completeness < 100 && (
          <p className="text-xs text-muted-foreground">
            Complete your profile to increase visibility and connect with more professionals.
          </p>
        )}
      </CardContent>
    </Card>
  );
};

export default ProfileCompletenessCard;
