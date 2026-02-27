package com.google.firebase.example.makeitso.ui.taskList

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import com.google.firebase.example.makeitso.data.model.Task
import com.google.firebase.example.makeitso.data.model.TaskPriority
import com.google.firebase.example.makeitso.ui.theme.BrightBlue
import com.google.firebase.example.makeitso.ui.theme.DeepDark
import com.google.firebase.example.makeitso.ui.theme.HighlightBlue
import com.google.firebase.example.makeitso.ui.theme.LightBlue
import com.google.firebase.example.makeitso.ui.theme.MakeItSoTheme
import kotlinx.serialization.Serializable
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Serializable
object TaskListRoute

@Composable
fun TaskListScreen(
    openNewTaskScreen: () -> Unit,
    viewModel: TaskListViewModel = hiltViewModel()
) {
    val tasks by viewModel.tasks.collectAsState(initial = emptyList())

    TaskListScreenContent(
        tasks = tasks,
        openNewTaskScreen = openNewTaskScreen,
        onTaskCheckChange = viewModel::onTaskCheckChange,
        onDeleteTask = viewModel::onDeleteTask
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TaskListScreenContent(
    tasks: List<Task>,
    openNewTaskScreen: () -> Unit = {},
    onTaskCheckChange: (Task) -> Unit = {},
    onDeleteTask: (Task) -> Unit = {}
) {
    val activeTasks = tasks.filter { !it.isCompleted }
    val completedTasks = tasks.filter { it.isCompleted }

    Scaffold(
        containerColor = if (isSystemInDarkTheme()) DeepDark else Color.White,
        topBar = {
            TopAppBar(
                title = { 
                    Text(
                        "Tasks", 
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontWeight = FontWeight.Bold
                        )
                    ) 
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = if (isSystemInDarkTheme()) DeepDark else Color.White
                )
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = openNewTaskScreen,
                containerColor = HighlightBlue,
                contentColor = Color.White
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add Task")
            }
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .padding(paddingValues)
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            if (activeTasks.isNotEmpty()) {
                item {
                    SectionHeader(title = "ACTIVE TASKS", count = activeTasks.size)
                }
                items(activeTasks) { task ->
                    TaskItemCard(
                        task = task,
                        onCheckChange = { onTaskCheckChange(task) },
                        onDelete = { onDeleteTask(task) }
                    )
                }
            }

            if (completedTasks.isNotEmpty()) {
                item {
                    Spacer(modifier = Modifier.height(16.dp))
                    SectionHeader(title = "COMPLETED", count = completedTasks.size)
                }
                items(completedTasks) { task ->
                    TaskItemCard(
                        task = task,
                        onCheckChange = { onTaskCheckChange(task) },
                        onDelete = { onDeleteTask(task) }
                    )
                }
            }

            item { Spacer(modifier = Modifier.height(80.dp)) }
        }
    }
}

@Composable
fun SectionHeader(title: String, count: Int) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.labelLarge.copy(
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = Color.Gray
            )
        )
        Surface(
            color = if (isSystemInDarkTheme()) LightBlue.copy(alpha = 0.3f) else DeepDark,
            shape = RoundedCornerShape(50),
        ) {
            Text(
                text = "$count Items",
                style = MaterialTheme.typography.labelSmall.copy(color = BrightBlue),
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
            )
        }
    }
}

@Composable
fun TaskItemCard(
    task: Task,
    onCheckChange: () -> Unit,
    onDelete: () -> Unit
) {
    val cardColor = Color(0xFF161F2C)
    
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = cardColor),
        modifier = Modifier
            .fillMaxWidth()
            .border(1.dp, Color(0xFF2B374A), RoundedCornerShape(16.dp))
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.Top
        ) {
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .border(2.dp, if(task.isCompleted) Color(0xFF3B82F6) else Color.Gray, RoundedCornerShape(6.dp))
                    .background(if(task.isCompleted) Color(0xFF3B82F6) else Color.Transparent)
                    .clickable { onCheckChange() },
                contentAlignment = Alignment.Center
            ) {
                if (task.isCompleted) {
                    Icon(
                        Icons.Default.Check, 
                        contentDescription = null, 
                        tint = Color.White, 
                        modifier = Modifier.size(16.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = task.title,
                    style = MaterialTheme.typography.bodyLarge.copy(
                        color = Color.White,
                        fontWeight = FontWeight.Medium,
                        textDecoration = if (task.isCompleted) TextDecoration.LineThrough else TextDecoration.None
                    )
                )
                
                Spacer(modifier = Modifier.height(4.dp))
                
                Row(verticalAlignment = Alignment.CenterVertically) {
                    val dateColor = Color.Gray
                    val icon = if(task.isCompleted) Icons.Default.CheckCircle else Icons.Default.DateRange
                    
                    Icon(
                        imageVector = icon,
                        contentDescription = "Date",
                        tint = dateColor,
                        modifier = Modifier.size(14.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    val dateText = if (task.isCompleted) "Completed" else formatTaskDate(task.dueDate)
                    Text(
                        text = dateText,
                        style = MaterialTheme.typography.bodySmall.copy(color = dateColor)
                    )
                }
            }

            Spacer(modifier = Modifier.width(8.dp))

            PriorityBadge(priority = task.priority)
            
            Spacer(modifier = Modifier.width(8.dp))

            IconButton(onClick = onDelete, modifier = Modifier.size(24.dp)) {
                 Icon(Icons.Default.Close, contentDescription = "Delete", tint = Color.Gray)
            }
        }
    }
}

@Composable
fun PriorityBadge(priority: TaskPriority) {
    val (color, text) = when (priority) {
        TaskPriority.High -> Color(0xFFEF4444) to "HIGH"
        TaskPriority.Medium -> Color(0xFFF59E0B) to "MEDIUM"
        TaskPriority.Low -> Color(0xFF3B82F6) to "LOW"
    }

    Surface(
        color = color.copy(alpha = 0.1f),
        border = androidx.compose.foundation.BorderStroke(1.dp, color.copy(alpha = 0.3f)),
        shape = RoundedCornerShape(4.dp)
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.labelSmall.copy(
                fontSize = 10.sp, 
                fontWeight = FontWeight.Bold,
                color = color
            ),
            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
        )
    }
}

fun formatTaskDate(date: Date?): String {
    if (date == null) return ""
    val formatter = SimpleDateFormat("MMM dd, h:mm a", Locale.getDefault())
    return formatter.format(date)
}

@Preview(showBackground = true)
@Composable
fun TaskListScreenPreview() {
    MakeItSoTheme { 
        TaskListScreenContent(listOf(Task(title = "Task 1", dueDate = Date())))
    }
}